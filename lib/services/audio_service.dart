import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final Set<AudioPlayer> _activePlayers = {};
  AudioPlayer? _currentlyPlayingPlayer;
  
  Future<AudioPlayer> loadAudio(String fileName) async {
    final player = AudioPlayer();
    try {
      await player.setAsset('assets/audio/$fileName.mp3');
      _activePlayers.add(player);
      return player;
    } catch (e) {
      debugPrint('Error loading audio: $e');
      rethrow;
    }
  }
  
  // Регистрируем плеер при его создании
  void registerPlayer(AudioPlayer player) {
    _activePlayers.add(player);
  }
  
  // Удаляем плеер из списка активных при его удалении
  void unregisterPlayer(AudioPlayer player) {
    _activePlayers.remove(player);
    if (_currentlyPlayingPlayer == player) {
      _currentlyPlayingPlayer = null;
    }
  }
  
  // Останавливаем все плееры кроме указанного
  Future<void> stopAllExcept(AudioPlayer? exceptPlayer) async {
    for (var player in _activePlayers) {
      if (player != exceptPlayer) {
        try {
          await player.pause();
        } catch (e) {
          debugPrint('Error stopping player: $e');
        }
      }
    }
    _currentlyPlayingPlayer = exceptPlayer;
  }
  
  // Останавливаем все плееры
  Future<void> stopAll() async {
    for (var player in _activePlayers) {
      try {
        await player.pause();
      } catch (e) {
        debugPrint('Error stopping player: $e');
      }
    }
    _currentlyPlayingPlayer = null;
  }
  
  Future<void> dispose() async {
    await stopAll();
    for (var player in _activePlayers) {
      try {
        await player.dispose();
      } catch (e) {
        debugPrint('Error disposing player: $e');
      }
    }
    _activePlayers.clear();
    _currentlyPlayingPlayer = null;
  }
}
