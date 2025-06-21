// lib/components/button_widget.dart
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? fontSize;
  final double? verticalPadding;
  final double? borderRadius;
  final double? elevation;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.fontSize,
    this.verticalPadding,
    this.borderRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blue[700],
          foregroundColor: foregroundColor ?? Colors.white,
          padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 15),
          ),
          elevation: elevation ?? 7,
          shadowColor: Colors.blue[900]?.withOpacity(0.6),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          text,
          style: TextStyle(fontSize: fontSize ?? 19, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}