import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Language.dart';
import '../api.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({Key? key}) : super(key: key);

  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  String _inputText = '';
  String _translatedText = '';
  final TranslatorAPI _translatorAPI = TranslatorAPI();

  // Language list and default selections
  final List<Language> _languages = [
    Language('en', 'English'),
    Language('sv', 'Swedish'),
    Language('fr', 'French'),
    // Add more languages here if needed
  ];
  Language? _sourceLanguage;
  Language? _targetLanguage;

  @override
  void initState() {
    super.initState();
    _sourceLanguage = _languages[0];
    _targetLanguage = _languages[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translate Text')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<Language>(
              value: _sourceLanguage,
              items: _languages.map((Language lang) {
                return DropdownMenuItem<Language>(
                  value: lang,
                  child: Text(lang.name),
                );
              }).toList(),
              onChanged: (Language? newValue) {
                setState(() {
                  _sourceLanguage = newValue!;
                });
              },
              hint: const Text("Select source language"),
            ),
            DropdownButton<Language>(
              value: _targetLanguage,
              items: _languages.map((Language lang) {
                return DropdownMenuItem<Language>(
                  value: lang,
                  child: Text(lang.name),
                );
              }).toList(),
              onChanged: (Language? newValue) {
                setState(() {
                  _targetLanguage = newValue!;
                });
              },
              hint: const Text("Select target language"),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _inputText = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Enter text to translate',
              ),
            ),
            ElevatedButton(
              child: const Text('Translate'),
              onPressed: () async {
                try {
                  String result = await _translatorAPI.translateText(
                    _inputText,
                    _sourceLanguage!.code,
                    _targetLanguage!.code,
                  );
                  setState(() {
                    _translatedText = result;
                  });

                  // Add translation to Firestore
                  final FirebaseFirestore firestore = FirebaseFirestore.instance;
                  await firestore.collection('translations').add({
                    'originalText': _inputText,
                    'translatedText': _translatedText,
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                } catch (e) {
                  print("Error: $e");
                  const snackBar = SnackBar(
                    content: Text('Failed to translate. Please try again.'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
            Text('Translated Text: $_translatedText'),
            ElevatedButton(
              child: const Text('Copy to Clipboard'),
              onPressed: () {
                FlutterClipboard.copy(_translatedText).then((result) {
                  const snackBar = SnackBar(
                    content: Text('Copied to Clipboard!'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
