// lib/components/text_form_field_widget.dart
import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final int? maxLines;

  // Puedes añadir un color para el icono y los bordes si quieres que sea configurable
  // final Color? iconColor;
  // final Color? borderColor;

  const TextFormFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    // this.iconColor, // Si decides hacerlo configurable
    // this.borderColor, // Si decides hacerlo configurable
  });

  @override
  Widget build(BuildContext context) {
    // Definimos los colores base para los bordes y el icono
    // Puedes usar los que mejor se adapten a tu "azul formal"
    final Color blueAccent = Colors.blueAccent;
    final Color bluePrimary = Colors.blue;
    final Color blueDark = Colors.blue[800]!; // Un azul más oscuro para el foco

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
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[600]), // Color para el hintText
          prefixIcon: Icon(icon, color: blueAccent), // Icono con color azul

          // Bordes de estilo "OutlineInputBorder" con los colores azules formales
          border: OutlineInputBorder( // Borde por defecto
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: blueAccent), // Color del borde por defecto
          ),
          enabledBorder: OutlineInputBorder( // Borde cuando el campo no está enfocado
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: blueAccent, width: 1.5), // Color y grosor
          ),
          focusedBorder: OutlineInputBorder( // Borde cuando el campo está enfocado
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: bluePrimary, width: 2.5), // Color más oscuro y más grueso
          ),

          // Puedes ajustar el color de la etiqueta si tu TextFormFieldWidget lo usara
          // labelStyle: TextStyle(color: blueAccent),

          // Mantener los bordes de error rojos
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),

          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}