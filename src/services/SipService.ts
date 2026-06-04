import {
  UserAgent,
  UserAgentOptions,
  Invitation,
  Session,
  SessionState,
  Registerer,
  UserAgentState,
} from 'sip.js';
import {
  mediaDevices,
  MediaStream,
} from 'react-native-webrtc';

export interface SipConfig {
  uri: string; // e.g., sip:1001@pbx.example.com
  wsServer: string; // e.g., wss://pbx.example.com:8089/ws
  password?: string;
  displayName?: string;
}

class SipService {
  private userAgent: UserAgent | null = null;
  private registerer: Registerer | null = null;
  private currentSession: Session | null = null;
  private localStream: MediaStream | null = null;

  public onRegistrationChange?: (registered: boolean) => void;
  public onCallStateChange?: (state: string) => void;
  public onIncomingCall?: (invitation: Invitation) => void;
  public onRemoteStream?: (stream: MediaStream) => void;

  async initialize(config: SipConfig) {
    const userAgentOptions: UserAgentOptions = {
      uri: UserAgent.makeURI(config.uri),
      transportOptions: {
        server: config.wsServer,
      },
      authorizationPassword: config.password,
      authorizationUsername: config.uri.split('@')[0].split(':')[1],
      displayName: config.displayName,
      // React Native doesn't have a default SessionDescriptionHandler that works perfectly with react-native-webrtc
      // Usually we need to use a shim or custom handler.
      // sip.js/lib/platform/web's SimpleUser might work if we shim globals.
    };

    this.userAgent = new UserAgent(userAgentOptions);

    this.userAgent.delegate = {
      onInvite: (invitation: Invitation) => {
        console.log('Incoming call');
        this.currentSession = invitation;
        this.setupSessionHandler(invitation);
        if (this.onIncomingCall) this.onIncomingCall(invitation);
      },
    };

    this.userAgent.stateChange.addListener((state: UserAgentState) => {
      console.log('UA State:', state);
    });

    await this.userAgent.start();

    this.registerer = new Registerer(this.userAgent);
    await this.registerer.register();
    if (this.onRegistrationChange) this.onRegistrationChange(true);
  }

  private setupSessionHandler(session: Session) {
    session.stateChange.addListener((state: SessionState) => {
      if (this.onCallStateChange) this.onCallStateChange(state);

      if (state === SessionState.Terminated) {
        this.currentSession = null;
        this.localStream = null;
      }
    });

    // In a production app, you'd handle the SessionDescriptionHandler to attach streams
    // For this POC, we assume sip.js is configured to use react-native-webrtc shims
  }

  async makeCall(targetUri: string) {
    if (!this.userAgent) return;

    const target = UserAgent.makeURI(targetUri);
    if (!target) throw new Error('Invalid target URI');

    // Request microphone permission and get stream
    const stream = await mediaDevices.getUserMedia({
      audio: true,
      video: false,
    }) as MediaStream;
    this.localStream = stream;

    const inviterOptions = {
      sessionDescriptionHandlerOptions: {
        constraints: { audio: true, video: false },
        // Depending on the SDH implementation, you might pass the stream here
        // or the SDH will call getUserMedia itself.
      }
    };

    const inviter = new (require('sip.js').Inviter)(this.userAgent, target, inviterOptions);
    this.currentSession = inviter;
    this.setupSessionHandler(inviter);

    await inviter.invite();
  }

  async answerCall() {
    if (this.currentSession instanceof Invitation) {
      await this.currentSession.accept();
    }
  }

  async hangup() {
    if (this.currentSession) {
      if (this.currentSession.state === SessionState.Established) {
        await this.currentSession.bye();
      } else {
        await this.currentSession.cancel();
      }
    }
  }
}

export default new SipService();
