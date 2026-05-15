/// Dialpad page — entry point for dialling a number.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pbx_client_sample/presentation/blocs/call/call_bloc.dart';

class DialpadPage extends StatefulWidget {
  const DialpadPage({super.key});

  @override
  State<DialpadPage> createState() => _DialpadPageState();
}

class _DialpadPageState extends State<DialpadPage> {
  final TextEditingController _numberController = TextEditingController();

  void _onDigitTapped(String digit) {
    setState(() {
      _numberController.text += digit;
    });
  }

  void _onCall() {
    final destination = _numberController.text.trim();
    if (destination.isEmpty) return;
    context.read<CallBloc>().add(CallStarted(destination));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dialpad')),
      body: Column(
        children: [
          // ── Number display ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              controller: _numberController,
              readOnly: true,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),

          // ── Digit grid ──────────────────────────────────────────────
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              children: [
                for (final digit in [
                  '1', '2', '3',
                  '4', '5', '6',
                  '7', '8', '9',
                  '*', '0', '#',
                ])
                  _DialButton(digit: digit, onTap: _onDigitTapped),
              ],
            ),
          ),

          // ── Call button ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(32),
            child: FloatingActionButton.large(
              onPressed: _onCall,
              backgroundColor: Colors.green,
              child: const Icon(Icons.call, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }
}

class _DialButton extends StatelessWidget {
  final String digit;
  final ValueChanged<String> onTap;

  const _DialButton({required this.digit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(48),
      onTap: () => onTap(digit),
      child: Center(
        child: Text(
          digit,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
