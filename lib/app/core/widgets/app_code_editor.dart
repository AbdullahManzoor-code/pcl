import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app_card.dart';

class AppCodeEditor extends StatefulWidget {
  final String code;
  final String language;
  final VoidCallback? onRun;

  const AppCodeEditor({
    Key? key,
    required this.code,
    this.language = 'dart',
    this.onRun,
  }) : super(key: key);

  @override
  State<AppCodeEditor> createState() => _AppCodeEditorState();
}

class _AppCodeEditorState extends State<AppCodeEditor> {
  bool _isRunning = false;
  String? _output;

  void _runCode() async {
    setState(() {
      _isRunning = true;
      _output = null;
    });

    // Simulate code execution
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRunning = false;
      _output = widget.language.toLowerCase() == 'python'
          ? '>>> Python execution successful!\nOutput: Hello, World!'
          : 'Output: Code executed successfully.';
    });

    widget.onRun?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                _buildDot(Colors.red),
                const SizedBox(width: 6),
                _buildDot(Colors.amber),
                const SizedBox(width: 6),
                _buildDot(Colors.green),
                const SizedBox(width: 12),
                Text(
                  widget.language.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () {
                    // Mock copy
                    Get.snackbar(
                      'Copied',
                      'Code copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Theme.of(context).primaryColor,
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ),

          // Code Area
          Padding(
            padding: EdgeInsets.all(16.r),
            child: SelectableText(
              widget.code,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14.sp,
                color: isDark ? Colors.blue[200] : Colors.blue[900],
                height: 1.5,
              ),
            ),
          ),

          // Actions & Output
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runCode,
                  icon: _isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(_isRunning ? 'Running...' : 'Run Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 36),
                  ),
                ),
                if (_output != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      _output!,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.sp,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
