import 'dart:convert'; // Uncomment this
import 'package:http/http.dart' as http;

class TranslatorAPI {
  static const String baseUrl = "https://libretranslate.de/translate";

  Future<String> translateText(String text, String sourceLang, String targetLang) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: {
        "q": text,
        "source": sourceLang,
        "target": targetLang,
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);

      // Verify the correct key for the translated text
      return jsonResponse['translatedText']; // Adjust this key if necessary
    } else {
      throw Exception('Failed to load translation');
    }
  }
}
