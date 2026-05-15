/// Application entry point.
///
/// Sets up dependency injection by providing the appropriate service
/// (WebRtcService or SipService) based on saved user configuration,
/// then wires up Blocs before running the app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/repositories/connection_local_datasource.dart';
import 'data/services/webrtc/webrtc_service.dart';
import 'domain/entities/connection_entity.dart';
import 'presentation/blocs/call/call_bloc.dart';
import 'presentation/blocs/connection/connection_cubit.dart';
import 'presentation/pages/dialpad/dialpad_page.dart';
import 'presentation/pages/settings/settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final localDs = ConnectionLocalDataSource(prefs);
  final savedConfig = localDs.loadConfig();

  // Default to WebRTC service; swap to SipService when mode == sip.
  // TODO: factory pattern to switch service based on savedConfig.mode.
  final webRtcService = WebRtcService();

  if (savedConfig != null) {
    await webRtcService.connect(savedConfig);
  }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConnectionCubit(repository: webRtcService),
        ),
        BlocProvider(
          create: (_) => CallBloc(callRepository: webRtcService),
        ),
      ],
      child: const PbxClientApp(),
    ),
  );
}

class PbxClientApp extends StatelessWidget {
  const PbxClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PBX Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0057FF),
        brightness: Brightness.dark,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _pages = [
    DialpadPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dialpad), label: 'Dialpad'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
