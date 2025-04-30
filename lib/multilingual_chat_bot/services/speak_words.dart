import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

Future speak(String message) async {
  FlutterTts tts = FlutterTts();

  await tts.setLanguage("hi-IN"); // ✅ Set language to pure Hindi
  await tts.setSpeechRate(0.5); // Adjust speed
  await tts.setPitch(1.0); // Default pitch for natural sound
  await tts.setVolume(1.0); // Ensure full volume
  await tts.awaitSpeakCompletion(true);
  await tts.speak(message);
}
