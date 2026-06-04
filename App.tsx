import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  PermissionsAndroid,
  Platform,
  Alert,
} from 'react-native';
import SipService from './src/services/SipService';

const App = () => {
  const [wssUrl, setWssUrl] = useState('wss://your-pbx.com:8089/ws');
  const [sipUri, setSipUri] = useState('sip:1001@your-pbx.com');
  const [password, setPassword] = useState('password');
  const [targetUri, setTargetUri] = useState('sip:1002@your-pbx.com');

  const [regStatus, setRegStatus] = useState('Unregistered');
  const [callStatus, setCallStatus] = useState('Idle');

  useEffect(() => {
    requestPermissions();

    SipService.onRegistrationChange = (registered) => {
      setRegStatus(registered ? 'Registered' : 'Unregistered');
    };

    SipService.onCallStateChange = (state) => {
      setCallStatus(state);
    };

    SipService.onIncomingCall = (invitation) => {
      Alert.alert(
        'Incoming Call',
        `Call from ${invitation.remoteIdentity.uri.toString()}`,
        [
          { text: 'Answer', onPress: () => SipService.answerCall() },
          { text: 'Reject', onPress: () => SipService.hangup(), style: 'cancel' },
        ]
      );
    };
  }, []);

  const requestPermissions = async () => {
    if (Platform.OS === 'android') {
      try {
        const granted = await PermissionsAndroid.requestMultiple([
          PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
          PermissionsAndroid.PERMISSIONS.CAMERA,
        ]);
        if (
          granted['android.permission.RECORD_AUDIO'] !== PermissionsAndroid.RESULTS.GRANTED
        ) {
          console.log('Microphone permission denied');
        }
      } catch (err) {
        console.warn(err);
      }
    }
  };

  const handleConnect = async () => {
    try {
      setRegStatus('Connecting...');
      await SipService.initialize({
        uri: sipUri,
        wsServer: wssUrl,
        password: password,
        displayName: 'RN POC',
      });
    } catch (error) {
      console.error('Connection error:', error);
      setRegStatus('Error');
    }
  };

  const handleCall = async () => {
    try {
      await SipService.makeCall(targetUri);
    } catch (error) {
      console.error('Call error:', error);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>SIP WebRTC POC</Text>

        <View style={styles.statusBox}>
          <Text>Registration: {regStatus}</Text>
          <Text>Call: {callStatus}</Text>
        </View>

        <TextInput
          style={styles.input}
          placeholder="WSS URL"
          value={wssUrl}
          onChangeText={setWssUrl}
        />
        <TextInput
          style={styles.input}
          placeholder="SIP URI (sip:ext@domain)"
          value={sipUri}
          onChangeText={setSipUri}
        />
        <TextInput
          style={styles.input}
          placeholder="Password"
          secureTextEntry
          value={password}
          onChangeText={setPassword}
        />
        <TouchableOpacity style={styles.button} onPress={handleConnect}>
          <Text style={styles.buttonText}>Connect & Register</Text>
        </TouchableOpacity>

        <View style={styles.divider} />

        <TextInput
          style={styles.input}
          placeholder="Target SIP URI"
          value={targetUri}
          onChangeText={setTargetUri}
        />

        <View style={styles.row}>
          <TouchableOpacity style={[styles.button, { flex: 1, backgroundColor: 'green' }]} onPress={handleCall}>
            <Text style={styles.buttonText}>Call</Text>
          </TouchableOpacity>
          <TouchableOpacity style={[styles.button, { flex: 1, backgroundColor: 'red' }]} onPress={() => SipService.hangup()}>
            <Text style={styles.buttonText}>Hangup</Text>
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5FCFF' },
  content: { padding: 20 },
  title: { fontSize: 20, fontWeight: 'bold', marginBottom: 20, textAlign: 'center' },
  statusBox: { padding: 10, backgroundColor: '#eee', marginBottom: 20, borderRadius: 5 },
  input: { height: 40, borderColor: 'gray', borderWidth: 1, marginBottom: 10, paddingHorizontal: 10, borderRadius: 5 },
  button: { backgroundColor: '#2196F3', padding: 10, borderRadius: 5, alignItems: 'center', margin: 5 },
  buttonText: { color: 'white', fontWeight: 'bold' },
  row: { flexDirection: 'row' },
  divider: { height: 1, backgroundColor: '#ccc', marginVertical: 20 },
});

export default App;
