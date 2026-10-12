/// Provider-agnostic interface for the coach's language model.
///
/// Today this is implemented by [GeminiClient] (AI Studio key, REST). Moving to
/// Firebase AI Logic for a Play Store release only needs a new implementation.
abstract class CoachModel {
  /// Sends one request. [contents] uses the Gemini `contents` JSON shape
  /// (`{role, parts: [...]}`); [tools] are Gemini function declarations.
  Future<ModelTurn> generate({
    required String systemInstruction,
    required List<Map<String, dynamic>> contents,
    List<Map<String, dynamic>> tools = const [],
  });
}

class FunctionCall {
  final String name;
  final Map<String, dynamic> args;

  const FunctionCall(this.name, this.args);
}

class TokenUsage {
  final int promptTokens;
  final int outputTokens;

  const TokenUsage({this.promptTokens = 0, this.outputTokens = 0});
}

class ModelTurn {
  /// The model's raw `content` object. It must be sent back unchanged in the
  /// next request, because it can carry thought signatures that Gemini
  /// requires for function calling.
  final Map<String, dynamic> rawContent;
  final String text;
  final List<FunctionCall> functionCalls;
  final TokenUsage usage;

  const ModelTurn({
    required this.rawContent,
    required this.text,
    required this.functionCalls,
    this.usage = const TokenUsage(),
  });
}

enum CoachErrorKind { invalidKey, rateLimited, network, blocked, server, unknown }

class CoachModelException implements Exception {
  final CoachErrorKind kind;
  final String message;

  const CoachModelException(this.kind, this.message);

  /// Short, friendly text for the chat UI.
  String get userMessage {
    switch (kind) {
      case CoachErrorKind.invalidKey:
        return 'Your Gemini API key was rejected. Check it in Settings.';
      case CoachErrorKind.rateLimited:
        return 'Free-tier limit reached for now. Wait a minute and try again '
            '(daily limits reset at midnight Pacific time).';
      case CoachErrorKind.network:
        return 'No connection to Gemini. Check your internet and try again.';
      case CoachErrorKind.blocked:
        return 'Gemini declined to answer that. Try rephrasing.';
      case CoachErrorKind.server:
        return 'Gemini is having trouble right now. Try again shortly.';
      case CoachErrorKind.unknown:
        return 'Something went wrong: $message';
    }
  }

  @override
  String toString() => 'CoachModelException($kind): $message';
}
