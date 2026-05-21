import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:serat/Data/Shared/cache_helper.dart';

class GeminiService {
  // Try to use a saved key, otherwise fallback to empty (handling empty internally or prompting)
  static String? get _apiKey => CacheHelper.getData(key: 'gemini_api_key'); 

  // In production, we'll want to either pass the key or prompt the user.
  // For the sake of this prompt, we can try to initialize with the saved key.
  
  Future<String> generateText(String prompt) async {
    const String defaultKey = "PLACEHOLDER_API_KEY"; // Replace with real one or get from env
    final String keyToUse = _apiKey ?? defaultKey;

    if (keyToUse == "PLACEHOLDER_API_KEY") {
        return '''```json
{
  "accepted": false,
  "suggestion": "يرجى إضافة مفتاح API لـ Gemini في الإعدادات ليعمل هذا الوسام."
}
```''';
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash', // fast model for evaluation
        apiKey: keyToUse,
      );

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? '''```json
{
  "accepted": false,
  "suggestion": "عذرا، لم أتمكن من تقييم موقفك الآن."
}
```''';
    } catch (e) {
      return '''```json
{
  "accepted": false,
  "suggestion": "حدث خطأ في الاتصال بالذكاء الاصطناعي."
}
```''';
    }
  }
}
