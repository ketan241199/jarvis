import 'package:equatable/equatable.dart';
import '../../../services/speech_service.dart';

abstract class SpeechState extends Equatable {
  const SpeechState();

  @override
  List<Object?> get props => [];
}

class SpeechIdle extends SpeechState {
  const SpeechIdle();
}

class SpeechListening extends SpeechState {
  final String partialText;

  const SpeechListening({this.partialText = ''});

  @override
  List<Object?> get props => [partialText];
}

class SpeechResult extends SpeechState {
  final String recognizedText;
  final VoiceCommand command;

  const SpeechResult({
    required this.recognizedText,
    required this.command,
  });

  @override
  List<Object?> get props => [recognizedText, command];
}

class SpeechUnavailable extends SpeechState {
  const SpeechUnavailable();
}

class SpeechError extends SpeechState {
  final String message;

  const SpeechError(this.message);

  @override
  List<Object?> get props => [message];
}
