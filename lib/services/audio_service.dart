import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _currentPlayer;
  
  Future<AudioPlayer> loadAudio(String fileName) async {
    // Останавливаем предыдущий проигрыватель
    await stopAll();
    
    final player = AudioPlayer();
    try {
      await player.setAsset('assets/audio/$fileName.mp3');
      _currentPlayer = player;
      return player;
    } catch (e) {
      debugPrint('Error loading audio: $e');
      rethrow;
    }
  }
  
  Future<void> stopAll() async {
    if (_currentPlayer != null) {
      await _currentPlayer!.stop();
      await _currentPlayer!.dispose();
      _currentPlayer = null;
    }
  }
  
  Future<void> dispose() async {
    await stopAll();
  }
}
