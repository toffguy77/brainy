import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:games_services/games_services.dart';
import '../../models/leaderboard_entry.dart';

class GameServicesService {
  bool _isSignedIn = false;
  String? _playerName;

  bool get isSignedIn => _isSignedIn;
  String? get playerName => _playerName;

  /// Sign in to Game Center (iOS) / Play Games (Android).
  /// Call at app startup. Returns true if signed in successfully.
  Future<bool> signIn() async {
    try {
      await GamesServices.signIn();
      _isSignedIn = await GamesServices.isSignedIn;
      if (_isSignedIn) {
        _playerName = await GamesServices.getPlayerName();
      }
      return _isSignedIn;
    } on PlatformException {
      _isSignedIn = false;
      return false;
    }
  }

  /// Submit weekly XP score to the weekly leaderboard.
  Future<void> submitWeeklyXp(int xp) async {
    if (!_isSignedIn) return;
    try {
      await GamesServices.submitScore(
        score: Score(
          iOSLeaderboardID: weeklyXpLeaderboardId(platform: 'ios'),
          androidLeaderboardID: weeklyXpLeaderboardId(platform: 'android'),
          value: xp,
        ),
      );
    } on PlatformException {
      // Silently fail — score will be retried next session
    }
  }

  /// Submit best time (in milliseconds) for a specific grid size.
  Future<void> submitBestTime({
    required int gridSize,
    required int timeMs,
  }) async {
    if (!_isSignedIn) return;
    try {
      await GamesServices.submitScore(
        score: Score(
          iOSLeaderboardID: bestTimeLeaderboardId(gridSize: gridSize, platform: 'ios'),
          androidLeaderboardID: bestTimeLeaderboardId(gridSize: gridSize, platform: 'android'),
          value: timeMs,
        ),
      );
    } on PlatformException {
      // Silently fail
    }
  }

  /// Load top players from the weekly XP leaderboard.
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard({int count = 25}) async {
    if (!_isSignedIn) return [];
    try {
      final scores = await GamesServices.loadLeaderboardScores(
        iOSLeaderboardID: weeklyXpLeaderboardId(platform: 'ios'),
        androidLeaderboardID: weeklyXpLeaderboardId(platform: 'android'),
        scope: PlayerScope.global,
        timeScope: TimeScope.week,
        maxResults: count,
      );
      if (scores == null) return [];
      return scores
          .map((s) => LeaderboardEntry(
                playerName: s.scoreHolder.displayName,
                score: s.rawScore,
                rank: s.rank,
                isCurrentPlayer: false,
              ))
          .toList();
    } on PlatformException {
      return [];
    }
  }

  /// Open the native Game Center / Play Games leaderboard UI.
  Future<void> showNativeLeaderboards() async {
    try {
      await GamesServices.showLeaderboards(
        iOSLeaderboardID: weeklyXpLeaderboardId(platform: 'ios'),
        androidLeaderboardID: weeklyXpLeaderboardId(platform: 'android'),
      );
    } on PlatformException {
      // Native UI unavailable
    }
  }

  // --- Leaderboard ID helpers ---

  static String weeklyXpLeaderboardId({required String platform}) {
    return 'brainy_weekly_xp';
  }

  static String bestTimeLeaderboardId({
    required int gridSize,
    required String platform,
  }) {
    return 'brainy_best_time_${gridSize}x$gridSize';
  }
}
