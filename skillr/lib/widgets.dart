import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

InputDecoration textFormDecoration(title,hint, icon, {required context}) {
  return InputDecoration(
      labelText: title,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      prefixIcon: Icon(icon),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primaryContainer, width: 4),
      ),
    );
}

ButtonStyle bottomLargeButton(context) {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(
        Theme.of(context).colorScheme.primaryContainer),
    padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(vertical: 16)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
  );
}