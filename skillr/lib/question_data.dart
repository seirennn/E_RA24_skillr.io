import 'dart:convert';

// Define a class to hold question data
class QuestionData {
  // Define class properties
  final List<String> titles;
  final List<List<String>> options;

  // Define a constructor for the class
  QuestionData({required this.titles, required this.options});