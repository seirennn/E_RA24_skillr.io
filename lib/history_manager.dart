import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class HistoryManager {
  static final HistoryManager _instance = HistoryManager._internal();

  factory HistoryManager() {
    return _instance;
  }

  HistoryManager._internal();

  final String _fileName = 'history.json';
  List<Map<String, dynamic>> _history = [];

  Future<void> loadHistory() async {
    try {
      final file = File(_fileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        _history = List<Map<String, dynamic>>.from(json.decode(contents));
      }
    } catch (e) {
      debugPrint('Failed to load history: $e');
    }
  }

  Future<void> saveHistory() async {
    try {
      final file = File(_fileName);
      await file.writeAsString(json.encode(_history));
    } catch (e) {
      debugPrint('Failed to save history: $e');
    }
  }

  void addConversation(Map<String, dynamic> conversation) {
    _history.add(conversation);
  }

  List<Map<String, dynamic>> getHistory() {
    return List<Map<String, dynamic>>.from(_history);
  }
}
