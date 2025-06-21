import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final String hint;
  final bool obscure;
  final TextEditingController controller;
  final IconData suffixIcon;

  const TextInput(
      {super.key,
      this.obscure = false,
      required this.hint,
      required this.controller,
      required this.suffixIcon});

  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFE3EED4), // Fondo del contenedor (color claro)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError
              ? Color(0xFFAEC3B0)
              : Color(0xFF6B9071), // Borde dependiendo del error
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscure,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hint,
          fillColor: Color(0xFFE3EED4), // Fondo del input
          hintStyle: TextStyle(
            color: Color(0xFFAEC3B0), // Texto del placeholder
          ),
          suffixIcon: widget.suffixIcon != null
              ? Icon(
                  widget.suffixIcon,
                  size: 16,
                  color: Color(0xFF375534), // Color del ícono de sufijo
                )
              : null,
        ),
        style: TextStyle(
          color: Color(0xFF0F2A1D), // Texto dentro del input
        ),
        validator: (value) {
          setState(() {
            hasError = false;
          });

          if (value == null || value.isEmpty) {
            setState(() {
              hasError = true;
            });
            return null;
          }

          return null;
        },
      ),
    );
  }
}
