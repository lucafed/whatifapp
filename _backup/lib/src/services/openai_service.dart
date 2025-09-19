
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../util/types.dart';

class OpenAIService {
  static const _apiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-4o-mini';

  Future<Scenario> _call(String systemPrompt, String userPrompt) async {
    if (_apiKey.isEmpty) {
      // Mock
      return Scenario(
        shortText: 'Esempio (mock) senza chiave.',
        longText: 'Testo lungo di esempio per mostrare il comportamento in assenza di chiave.',
        probability: 52,
        rationale: 'Motivazione fittizia.',
      );
    }
    final body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
      'temperature': 0.9,
      'max_tokens': 700,
      'n': 1
    };
    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {'Authorization':'Bearer $_apiKey','Content-Type':'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('OpenAI error: ${res.statusCode} ${res.body}');
    }
    final data = jsonDecode(res.body);
    final text = (data['choices'][0]['message']['content'] ?? '').toString();
    Map<String,dynamic> toMap(String s) {
      final start = s.indexOf('{'); final end = s.lastIndexOf('}');
      final seg = (start>=0 && end>start) ? s.substring(start, end+1) : '{}';
      return jsonDecode(seg) as Map<String,dynamic>;
    }
    return Scenario.fromJson(toMap(text));
  }

  Future<DualResult> generateScenarios({required String question, required bool isFuture}) async {
    final user = 'Contesto temporale: ${isFuture ? 'FUTURO' : 'PASSATO'}\nDomanda: "$question"\nRispondi in JSON con chiavi: short, long, prob (0..100), why.';
    final slidingSys = 'Sei "Sliding Doors": stile realistico, concreto, non banale. Output solo JSON.';
    final wtfSys = 'Sei "What the F?!": stile ironico, colorato, plausibile ma sorprendente. Output solo JSON.';

    final sliding = await _call(slidingSys, user);
    final wtf = await _call(wtfSys, user);

    int clamp(int v)=> v.clamp(0,100);
    return DualResult(
      Scenario(shortText: sliding.shortText, longText: sliding.longText, probability: clamp(sliding.probability), rationale: sliding.rationale, likes: 0),
      Scenario(shortText: wtf.shortText, longText: wtf.longText, probability: clamp(wtf.probability), rationale: wtf.rationale, likes: 0),
    );
  }
}

class DualResult {
  final Scenario sliding;
  final Scenario wtf;
  DualResult(this.sliding, this.wtf);
}
