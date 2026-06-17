import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/speech_service.dart';
import 'speech_state.dart';

/// Cubit managing speech-to-text state.
class SpeechCubit extends Cubit<SpeechState> {
  final SpeechService _speechService;

  SpeechCubit({required SpeechService speechService})
      : _speechService = speechService,
        super(const SpeechIdle());

  /// Initializes the speech recognizer and starts listening.
  Future<void> startListening() async {
    try {
      final available = await _speechService.initialize();
      if (!available) {
        emit(const SpeechUnavailable());
        return;
      }

      emit(const SpeechListening());

      await _speechService.startListening(
        onResult: (text, isFinal) {
          if (isFinal) {
            final command = SpeechService.parseCommand(text);
            emit(SpeechResult(
              recognizedText: text,
              command: command,
            ));
          } else {
            emit(SpeechListening(partialText: text));
          }
        },
      );
    } catch (e) {
      emit(SpeechError(e.toString()));
    }
  }

  /// Stops listening.
  Future<void> stopListening() async {
    await _speechService.stopListening();
    if (state is SpeechListening) {
      emit(const SpeechIdle());
    }
  }

  /// Resets back to idle state.
  void reset() {
    emit(const SpeechIdle());
  }

  @override
  Future<void> close() {
    _speechService.dispose();
    return super.close();
  }
}
