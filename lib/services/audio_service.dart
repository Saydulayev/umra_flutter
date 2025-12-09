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
      // УЛУЧШЕНИЕ: Убеждаемся, что плеер удаляется при ошибке загрузки
      try {
        await player.dispose();
      } catch (disposeError) {
        debugPrint('Error disposing player after load failure: $disposeError');
      }
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
    // УЛУЧШЕНИЕ: Создаем копию списка для безопасной итерации
    final playersToStop = _activePlayers.toList();
    for (var player in playersToStop) {
      if (player != exceptPlayer) {
        try {
          await player.pause();
        } catch (e) {
          debugPrint('Error stopping player: $e');
          // Удаляем неработающий плеер из списка
          _activePlayers.remove(player);
        }
      }
    }
    _currentlyPlayingPlayer = exceptPlayer;
  }

  // Останавливаем все плееры
  Future<void> stopAll() async {
    // УЛУЧШЕНИЕ: Создаем копию списка для безопасной итерации
    final playersToStop = _activePlayers.toList();
    for (var player in playersToStop) {
      try {
        await player.pause();
      } catch (e) {
        debugPrint('Error stopping player: $e');
        // Удаляем неработающий плеер из списка
        _activePlayers.remove(player);
      }
    }
    _currentlyPlayingPlayer = null;
  }

  Future<void> dispose() async {
    await stopAll();
    // УЛУЧШЕНИЕ: Создаем копию списка для безопасной итерации
    final playersToDispose = _activePlayers.toList();
    for (var player in playersToDispose) {
      try {
        await player.dispose();
      } catch (e) {
        debugPrint('Error disposing player: $e');
      } finally {
        // Убеждаемся, что плеер удален из списка
        _activePlayers.remove(player);
      }
    }
    _activePlayers.clear();
    _currentlyPlayingPlayer = null;
  }
}
