import 'dart:async';
import 'package:flutter/material.dart';

/// Debouncer utility for search and input fields
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Debounced text field widget
class DebouncedTextField extends StatefulWidget {
  final String? hintText;
  final ValueChanged<String> onChanged;
  final Duration debounceDuration;
  final TextEditingController? controller;
  final InputDecoration? decoration;
  final TextStyle? style;

  const DebouncedTextField({
    super.key,
    this.hintText,
    required this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.controller,
    this.decoration,
    this.style,
  });

  @override
  State<DebouncedTextField> createState() => _DebouncedTextFieldState();
}

class _DebouncedTextFieldState extends State<DebouncedTextField> {
  late Debouncer _debouncer;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(delay: widget.debounceDuration);
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: widget.style,
      decoration:
          widget.decoration ??
          InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
      onChanged: (value) {
        _debouncer.call(() => widget.onChanged(value));
      },
    );
  }
}
