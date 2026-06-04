import { AppRegistry } from 'react-native';
import App from './App';
import { name as appName } from './app.json';

// SIP.js / WebRTC Polyfills
import { registerGlobals } from 'react-native-webrtc';
registerGlobals();

AppRegistry.registerComponent(appName, () => App);
