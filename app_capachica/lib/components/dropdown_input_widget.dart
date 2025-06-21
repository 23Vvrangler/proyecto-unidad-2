// lib/components/dropdown_input_widget.dart
import 'package:flutter/material.dart';

class DropdownInputWidget<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hintText;
  final IconData? icon;
  final String? Function(T?)? validator;
  final void Function(T?)? onChanged;

  const DropdownInputWidget({
    super.key,
    required this.items,
    required this.hintText,
    this.value,
    this.icon,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!.withOpacity(0.6),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(-5, 5),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: icon != null ? Icon(icon, color: Colors.blue[600]) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
        dropdownColor: Colors.white,
      ),
    );
  }
}
