import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Parsed result from a voice command.
class VoiceCommand {
  final VoiceAction action;
  final String content;
  final String? tag;

  const VoiceCommand({
    required this.action,
    required this.content,
    this.tag,
  });

  @override
  String toString() => 'VoiceCommand($action, "$content", tag: $tag)';
}

/// Possible actions from voice commands.
enum VoiceAction {
  addTask,
  removeTask,
  completeTask,
  showOverdue,
  unknown,
}

/// Service for speech-to-text functionality.
///
/// Wraps the `speech_to_text` package and provides voice command parsing.
class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  /// Whether the speech recognizer is currently listening.
  bool get isListening => _speech.isListening;

  /// Whether speech recognition is available on this device.
  bool get isAvailable => _isInitialized;

  /// Initializes the speech recognition engine.
  /// Returns true if initialization was successful.
  Future<bool> initialize() async {
    _isInitialized = await _speech.initialize(
      onError: (error) {
        // Error handling is managed by the Cubit
      },
      onStatus: (status) {
        // Status updates managed by the Cubit
      },
    );
    return _isInitialized;
  }

  /// Starts listening for speech input.
  ///
  /// [onResult] is called with the recognized text each time the
  /// recognizer produces a result (intermediate and final).
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  /// Stops listening for speech input.
  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Cancels the current listening session.
  Future<void> cancel() async {
    await _speech.cancel();
  }

  /// Parses a recognized text string into a [VoiceCommand].
  ///
  /// Supports commands like:
  /// - "add task buy groceries" → addTask with content "buy groceries"
  /// - "add work task send report" → addTask with tag "work"
  /// - "remove task buy groceries" → removeTask
  /// - "complete task send report" → completeTask
  /// - "show overdue" → showOverdue
  static VoiceCommand parseCommand(String text) {
    final lower = text.toLowerCase().trim();

    // Show overdue
    if (lower.contains('show overdue') || lower.contains('overdue tasks')) {
      return const VoiceCommand(
        action: VoiceAction.showOverdue,
        content: '',
      );
    }

    // Add task with tag
    final addWorkMatch = RegExp(r'add\s+(work|home|personal)\s+task\s+(.+)')
        .firstMatch(lower);
    if (addWorkMatch != null) {
      return VoiceCommand(
        action: VoiceAction.addTask,
        content: addWorkMatch.group(2)!.trim(),
        tag: addWorkMatch.group(1)!.trim(),
      );
    }

    // Add task (simple)
    final addMatch = RegExp(r'add\s+task\s+(.+)').firstMatch(lower);
    if (addMatch != null) {
      return VoiceCommand(
        action: VoiceAction.addTask,
        content: addMatch.group(1)!.trim(),
      );
    }

    // Remove / delete task
    final removeMatch =
        RegExp(r'(?:remove|delete)\s+task\s+(.+)').firstMatch(lower);
    if (removeMatch != null) {
      return VoiceCommand(
        action: VoiceAction.removeTask,
        content: removeMatch.group(1)!.trim(),
      );
    }

    // Complete / finish / done task
    final completeMatch =
        RegExp(r'(?:complete|finish|done|mark done)\s+task\s+(.+)')
            .firstMatch(lower);
    if (completeMatch != null) {
      return VoiceCommand(
        action: VoiceAction.completeTask,
        content: completeMatch.group(1)!.trim(),
      );
    }

    // If no command pattern matched, treat the entire text as task title
    return VoiceCommand(
      action: VoiceAction.addTask,
      content: text.trim(),
    );
  }

  /// Disposes the speech service.
  void dispose() {
    _speech.stop();
  }
}
