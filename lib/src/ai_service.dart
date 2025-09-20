import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class AiService {
  final String baseUrl = const String.fromEnvironment("API_BASE_URL", defaultValue: "http://10.0.2.2:3000");

  Future<String> ask(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/ask"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"prompt": prompt}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["reply"] ?? "Nessuna risposta";
      } else {
        return "Errore server: ${res.statusCode}";
      }
    } catch (e) {
      return "Errore connessione: $e";
    }
  }
}
