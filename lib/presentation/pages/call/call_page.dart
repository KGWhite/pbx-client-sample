/// In-call screen showing call status and call controls.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pbx_client_sample/domain/entities/call_entity.dart';
import 'package:pbx_client_sample/presentation/blocs/call/call_bloc.dart';

class CallPage extends StatelessWidget {
  final CallEntity call;
  const CallPage({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: BlocListener<CallBloc, CallState>(
        listener: (context, state) {
          if (state is CallTerminated || state is CallIdle) {
            Navigator.of(context).pop();
          }
        },
        child: SafeArea(
          child: BlocBuilder<CallBloc, CallState>(
            builder: (context, state) {
              final activeCall = state is CallActive
                  ? state.call
                  : state is CallInProgress
                      ? state.call
                      : call;

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ── Caller info ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
                        const SizedBox(height: 16),
                        Text(
                          activeCall.remoteDisplayName,
                          style: const TextStyle(color: Colors.white, fontSize: 28),
                        ),
                        Text(
                          activeCall.remoteNumber,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeCall.state.name.toUpperCase(),
                          style: const TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // ── Call controls ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _CallControl(
                              icon: activeCall.isMuted ? Icons.mic_off : Icons.mic,
                              label: activeCall.isMuted ? 'Unmute' : 'Mute',
                              onTap: () => context.read<CallBloc>().add(
                                    CallMuteToggled(
                                      activeCall.sessionId,
                                      mute: !activeCall.isMuted,
                                    ),
                                  ),
                            ),
                            _CallControl(
                              icon: activeCall.isOnHold ? Icons.play_arrow : Icons.pause,
                              label: activeCall.isOnHold ? 'Unhold' : 'Hold',
                              onTap: () => context.read<CallBloc>().add(
                                    CallHoldToggled(
                                      activeCall.sessionId,
                                      hold: !activeCall.isOnHold,
                                    ),
                                  ),
                            ),
                            _CallControl(
                              icon: Icons.dialpad,
                              label: 'Keypad',
                              onTap: () {
                                // TODO: show DTMF keypad overlay
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        FloatingActionButton.large(
                          onPressed: () => context
                              .read<CallBloc>()
                              .add(CallEnded(activeCall.sessionId)),
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.call_end, size: 40),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CallControl({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
