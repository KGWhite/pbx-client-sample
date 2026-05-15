/// Settings page for configuring SIP/WebRTC account and connection mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pbx_client_sample/core/constants/app_constants.dart';
import 'package:pbx_client_sample/domain/entities/connection_entity.dart';
import 'package:pbx_client_sample/presentation/blocs/connection/connection_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _hostController = TextEditingController();
  final _portController = TextEditingController(
    text: AppConstants.kDefaultWssPort.toString(),
  );
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _wssPathController = TextEditingController(
    text: AppConstants.kDefaultWssPath,
  );

  ConnectionMode _mode = ConnectionMode.webrtc;
  bool _useTls = true;

  void _onConnect() {
    if (!_formKey.currentState!.validate()) return;
    final config = ConnectionEntity(
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text) ?? AppConstants.kDefaultWssPort,
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim(),
      mode: _mode,
      wssPath: _wssPathController.text.trim(),
      useTls: _useTls,
    );
    context.read<ConnectionCubit>().connect(config);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connection Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Mode selector ──────────────────────────────────────
              Text('Connection Mode',
                  style: Theme.of(context).textTheme.titleMedium),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<ConnectionMode>(
                      title: const Text('WebRTC (WSS)'),
                      value: ConnectionMode.webrtc,
                      groupValue: _mode,
                      onChanged: (v) => setState(() => _mode = v!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<ConnectionMode>(
                      title: const Text('SIP'),
                      value: ConnectionMode.sip,
                      groupValue: _mode,
                      onChanged: (v) => setState(() => _mode = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Server fields ─────────────────────────────────────
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Asterisk Host',
                  hintText: 'pbx.example.com',
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _portController,
                      decoration: const InputDecoration(labelText: 'Port'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _wssPathController,
                      decoration: const InputDecoration(labelText: 'WSS Path'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Use TLS (wss:// / sips:)'),
                value: _useTls,
                onChanged: (v) => setState(() => _useTls = v),
              ),

              const Divider(height: 32),

              // ── Account fields ────────────────────────────────────
              Text('SIP Account',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Extension / Username'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
              ),

              const SizedBox(height: 32),

              // ── Registration status ───────────────────────────────
              BlocBuilder<ConnectionCubit, RegistrationStatus>(
                builder: (context, status) => Row(
                  children: [
                    Icon(
                      status == RegistrationStatus.registered
                          ? Icons.check_circle
                          : status == RegistrationStatus.registering
                              ? Icons.sync
                              : Icons.cancel,
                      color: status == RegistrationStatus.registered
                          ? Colors.green
                          : status == RegistrationStatus.registering
                              ? Colors.orange
                              : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(status.name.toUpperCase()),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onConnect,
                  child: const Text('Connect & Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    _wssPathController.dispose();
    super.dispose();
  }
}
