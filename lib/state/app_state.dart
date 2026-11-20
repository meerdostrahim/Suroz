import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// ─── Song Model ───────────────────────────────────────────────────────────────
class Song {
  final String id;
  final String title;
  final String subtitle;
  final Duration duration;
  final String artist;
  final String language;
  final List<String> tags;
  final bool isInstrumental;
  final String lyrics;
  final String coverPath;
  final bool isDraft;
  bool isSaved;
  final DateTime createdAt;

  Song({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.artist,
    required this.language,
    required this.tags,
    required this.isInstrumental,
    required this.lyrics,
    this.coverPath = '',
    this.isDraft = false,
    this.isSaved = false,
    required this.createdAt,
  });
}

// ─── UserProfile Model ────────────────────────────────────────────────────────
class UserProfile {
  String fullName;
  String username;
  String bio;
  String location;
  String website;
  String category;
  bool isPrivate;
  /// Index into a predefined gradient palette used as avatar background
  int avatarColorIndex;
  final DateTime joinedAt;

  UserProfile({
    required this.fullName,
    required this.username,
    this.bio =
        'Passionate AI music creator producing cinematic, electronic and lo-fi tracks. Creating music with AI for creators & filmmakers. 🎧✨',
    this.location = 'Balochistan, Pakistan',
    this.website = '',
    this.category = '🎵 AI Music Producer & Composer',
    this.isPrivate = false,
    this.avatarColorIndex = 0,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime(2024, 3, 15);

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? bio,
    String? location,
    String? website,
    String? category,
    bool? isPrivate,
    int? avatarColorIndex,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      category: category ?? this.category,
      isPrivate: isPrivate ?? this.isPrivate,
      avatarColorIndex: avatarColorIndex ?? this.avatarColorIndex,
      joinedAt: joinedAt,
    );
  }
}

// ─── Playlist Model ───────────────────────────────────────────────────────────
class Playlist {
  final String id;
  String name;
  /// Index into a predefined colour palette
  int coverColorIndex;
  final List<String> trackIds; // ordered list of Song.id
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    this.coverColorIndex = 0,
    List<String>? trackIds,
    DateTime? createdAt,
  })  : trackIds = trackIds ?? [],
        createdAt = createdAt ?? DateTime.now();
}

// ─── Follower / Following User Model ─────────────────────────────────────────
class FollowUser {
  final String id;
  final String name;
  final String username;
  final String subtitle;
  final int avatarColorIndex;
  bool isFollowing;

  FollowUser({
    required this.id,
    required this.name,
    required this.username,
    required this.subtitle,
    this.avatarColorIndex = 0,
    this.isFollowing = false,
  });
}

// ─── Story Highlight / Award Model ───────────────────────────────────────────
class ProfileHighlight {
  final String id;
  String title;
  IconData icon;
  int colorIndex;
  String? trackId;
  String description;

  ProfileHighlight({
    required this.id,
    required this.title,
    required this.icon,
    this.colorIndex = 0,
    this.trackId,
    this.description = 'Featured Story Highlight • SUROZ AI',
  });
}

// ─── AppState ─────────────────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  // ── Auth ──────────────────────────────────────────────────────────────────
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _currentUser;
  String? get currentUser => _currentUser;

  final Map<String, String> _users = {'creator': 'password'};

  // ── User Profiles (keyed by username) ────────────────────────────────────
  final Map<String, UserProfile> _profiles = {};

  UserProfile get profile {
    final user = _currentUser ?? 'creator';
    if (!_profiles.containsKey(user)) {
      _profiles[user] = UserProfile(
        fullName: _toDisplayName(user),
        username: user,
        website: 'suroz.ai/creator/$user',
      );
    }
    return _profiles[user]!;
  }

  void updateProfile(UserProfile updated) {
    _profiles[updated.username] = updated;
    notifyListeners();
  }

  // ── Auth methods ──────────────────────────────────────────────────────────
  bool login(String username, String password) {
    final trimUser = username.trim();
    _isLoggedIn = true;
    _currentUser = trimUser.isNotEmpty ? trimUser : 'creator';
    _ensureProfileExists(_currentUser!);
    notifyListeners();
    return true;
  }

  bool register(String username, String password) {
    final lowerUser = username.trim().toLowerCase();
    if (lowerUser.isEmpty || password.length < 6) return false;
    if (_users.containsKey(lowerUser)) return false;
    _users[lowerUser] = password;
    _isLoggedIn = true;
    _currentUser = username.trim();
    _ensureProfileExists(_currentUser!);
    notifyListeners();
    return true;
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;
    stopPlayback();
    _currentTabIndex = 0;
    notifyListeners();
  }

  void _ensureProfileExists(String username) {
    if (!_profiles.containsKey(username)) {
      _profiles[username] = UserProfile(
        fullName: _toDisplayName(username),
        username: username,
        website: 'suroz.ai/creator/$username',
      );
    }
  }

  // ── Credits ───────────────────────────────────────────────────────────────
  int _credits = 0;
  int get credits => _credits;

  void addCredits(int amount) {
    _credits += amount;
    notifyListeners();
  }

  // ── Songs ─────────────────────────────────────────────────────────────────
  final List<Song> _songs = [];

  final List<Song> _drafts = [];

  List<Song> get songs => _songs.where((s) => !s.isDraft).toList();
  List<Song> get drafts => _drafts;

  Song? getSongById(String id) {
    try {
      return _songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Playlists Per User ───────────────────────────────────────────────────
  final Map<String, List<Playlist>> _userPlaylists = {};

  // ── Saved Songs Per User ──────────────────────────────────────────────────
  final Map<String, Set<String>> _userSavedSongs = {};

  Set<String> _getSavedIds() {
    final user = _currentUser ?? 'creator';
    return _userSavedSongs.putIfAbsent(user, () => {});
  }

  List<Playlist> _getPlaylists() {
    final user = _currentUser ?? 'creator';
    return _userPlaylists.putIfAbsent(user, () => []);
  }

  bool isSongSaved(Song song) {
    return _getSavedIds().contains(song.id);
  }

  void toggleSaveSong(Song song) {
    final savedSet = _getSavedIds();
    if (savedSet.contains(song.id)) {
      savedSet.remove(song.id);
      song.isSaved = false;
    } else {
      savedSet.add(song.id);
      song.isSaved = true;
    }
    notifyListeners();
  }

  List<Song> get savedSongs =>
      _songs.where((s) => isSongSaved(s) && !s.isDraft).toList();

  List<Playlist> get playlists => List.unmodifiable(_getPlaylists());

  Playlist? getPlaylistById(String id) {
    try {
      return _getPlaylists().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Song> getPlaylistTracks(Playlist playlist) {
    return playlist.trackIds
        .map((id) => getSongById(id))
        .whereType<Song>()
        .toList();
  }

  void createPlaylist(String name, {int coverColorIndex = 0}) {
    final list = _getPlaylists();
    final playlist = Playlist(
      id: 'playlist_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      coverColorIndex: coverColorIndex,
    );
    list.insert(0, playlist);
    notifyListeners();
  }

  void deletePlaylist(String playlistId) {
    final list = _getPlaylists();
    list.removeWhere((p) => p.id == playlistId);
    notifyListeners();
  }

  void renamePlaylist(String playlistId, String newName) {
    final p = getPlaylistById(playlistId);
    if (p != null) {
      p.name = newName.trim();
      notifyListeners();
    }
  }

  void addTrackToPlaylist(String playlistId, String songId) {
    final p = getPlaylistById(playlistId);
    if (p != null && !p.trackIds.contains(songId)) {
      p.trackIds.add(songId);
      notifyListeners();
    }
  }

  void removeTrackFromPlaylist(String playlistId, String songId) {
    final p = getPlaylistById(playlistId);
    if (p != null) {
      p.trackIds.remove(songId);
      notifyListeners();
    }
  }

  // ── Followers & Following ─────────────────────────────────────────────────
  final List<FollowUser> _followers = [];

  final List<FollowUser> _following = [];

  List<FollowUser> get followers => List.unmodifiable(_followers);
  List<FollowUser> get followingList => _following.where((u) => u.isFollowing).toList();

  int get followersCount => _followers.length;
  int get followingCount => _following.where((u) => u.isFollowing).length;

  void toggleFollowUser(FollowUser user) {
    user.isFollowing = !user.isFollowing;
    final inFollowing = _following.firstWhere(
      (u) => u.username == user.username,
      orElse: () {
        final newUser = FollowUser(
          id: user.id,
          name: user.name,
          username: user.username,
          subtitle: user.subtitle,
          avatarColorIndex: user.avatarColorIndex,
          isFollowing: true,
        );
        _following.add(newUser);
        return newUser;
      },
    );
    inFollowing.isFollowing = user.isFollowing;

    for (var f in _followers) {
      if (f.username == user.username) {
        f.isFollowing = user.isFollowing;
      }
    }
    notifyListeners();
  }

  // ── Profile Highlights / Awards ───────────────────────────────────────────
  final List<ProfileHighlight> _highlights = [];

  List<ProfileHighlight> get highlights => List.unmodifiable(_highlights);

  void addHighlight({
    required String title,
    required IconData icon,
    int colorIndex = 0,
    String? trackId,
    String? description,
  }) {
    final highlight = ProfileHighlight(
      id: 'hl_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      icon: icon,
      colorIndex: colorIndex,
      trackId: trackId,
      description: description != null && description.trim().isNotEmpty
          ? description.trim()
          : 'Featured Story Highlight • SUROZ AI',
    );
    _highlights.add(highlight);
    notifyListeners();
  }

  void deleteHighlight(String highlightId) {
    _highlights.removeWhere((h) => h.id == highlightId);
    notifyListeners();
  }

  // ── Playback ──────────────────────────────────────────────────────────────
  Song? _currentSong;
  Song? get currentSong => _currentSong;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isRadioActive = false;
  bool get isRadioActive => _isRadioActive;

  Map<String, String> _radioTuning = {
    'mood': 'Calm',
    'voice': 'Instrumental',
    'instrument': 'Dambora',
    'region': 'Makkuran',
  };
  Map<String, String> get radioTuning => _radioTuning;

  String get radioStationName => 'Desert Night Radio';
  String get radioStationDescription =>
      'Slow strings, soft voice textures, and late-road atmosphere. '
      'Soft ${_radioTuning['instrument']} phrases over a ${_radioTuning['mood']?.toLowerCase()} ${_radioTuning['region']?.toLowerCase()} texture.';

  // ── Generation ────────────────────────────────────────────────────────────
  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  double _generationProgress = 0.0;
  double get generationProgress => _generationProgress;

  String _generationStatus = '';
  String get generationStatus => _generationStatus;

  // ── Tab Index ─────────────────────────────────────────────────────────────
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  // ── Play Controls ─────────────────────────────────────────────────────────
  void playSong(Song song) {
    if (_currentSong?.id == song.id && !_isRadioActive) {
      _isPlaying = !_isPlaying;
    } else {
      _isRadioActive = false;
      _currentSong = song;
      _isPlaying = true;
    }
    notifyListeners();
  }

  void playPlaylist(Playlist playlist) {
    final tracks = getPlaylistTracks(playlist);
    if (tracks.isNotEmpty) {
      playSong(tracks.first);
    }
  }

  void playRadio() {
    _isRadioActive = true;
    _currentSong = null;
    _isPlaying = true;
    notifyListeners();
  }

  void togglePlay() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void stopPlayback() {
    _isPlaying = false;
    _currentSong = null;
    _isRadioActive = false;
    notifyListeners();
  }

  void tuneRadio(String mood, String voice, String instrument, String region) {
    _radioTuning = {
      'mood': mood,
      'voice': voice,
      'instrument': instrument,
      'region': region,
    };
    if (_isRadioActive) {
      _isPlaying = false;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 500), () {
        _isPlaying = true;
        notifyListeners();
      });
    } else {
      playRadio();
    }
  }

  void captureRadioClip() {
    if (_credits < 10) return;
    _credits -= 10;

    final newClip = Song(
      id: 'capture_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Captured ${_radioTuning['instrument']} Drift',
      subtitle: '${_radioTuning['mood']} live stream fragment',
      duration: const Duration(seconds: 30),
      artist: '${_currentUser ?? 'creator'} & SUROZ AI',
      language: 'Balochi',
      tags: [_radioTuning['mood']!, _radioTuning['instrument']!],
      isInstrumental: _radioTuning['voice'] == 'Instrumental',
      lyrics: '',
      isSaved: true,
      createdAt: DateTime.now(),
    );
    _songs.insert(0, newClip);
    notifyListeners();
  }

  // ── Generation ────────────────────────────────────────────────────────────
  void generateSong({
    required String description,
    required String language,
    required bool isInstrumental,
    required String lyrics,
    String instrument = 'Dambora',
    String songType = 'Zahriok',
    String voice = 'Instrumental',
    String tempo = 'Moderate (90 BPM)',
    String scale = 'A Minor',
    String mood = 'Mystical',
    String energy = 'Moderate',
    String duration = '3:00',
    String intensity = 'Balanced',
    String creativity = 'Balanced',
    bool isAdvanced = false,
  }) {
    final cost = isAdvanced ? 30 : 20;
    if (_credits < cost || _isGenerating) return;

    _credits -= cost;
    _isGenerating = true;
    _generationProgress = 0.0;
    _generationStatus = 'Analyzing description...';
    notifyListeners();

    const steps = 4;
    int currentStep = 0;

    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      currentStep++;
      _generationProgress = currentStep / steps;

      switch (currentStep) {
        case 1:
          _generationStatus = 'Composing $instrument ($songType) melodies...';
          break;
        case 2:
          _generationStatus = isInstrumental
              ? 'Blending $instrument with $scale rhythms...'
              : 'Synthesizing $language $voice vocal harmonies...';
          break;
        case 3:
          _generationStatus = 'Mastering audio stream at $tempo...';
          break;
        case 4:
          timer.cancel();
          _isGenerating = false;
          _generationProgress = 1.0;

          final titles = [
            'Desert Whisper',
            'Makkuran Drift',
            'Suroz Evening Echoes',
            'Urdu Acoustic Breeze',
            'Golden Hour Dambora',
          ];
          final randomTitle = titles[Random().nextInt(titles.length)];

          final newSong = Song(
            id: 'gen_${DateTime.now().millisecondsSinceEpoch}',
            title: description.trim().isNotEmpty && description.length < 30
                ? description.trim()
                : randomTitle,
            subtitle: description.trim().isNotEmpty
                ? '$description ($songType · $instrument)'
                : 'AI Generated $language $songType ($instrument)',
            duration: const Duration(minutes: 3, seconds: 12),
            artist: '${_currentUser ?? 'creator'} & SUROZ AI',
            language: language,
            tags: [
              language,
              songType,
              instrument,
              isInstrumental ? 'Instrumental' : voice,
              scale,
            ],
            isInstrumental: isInstrumental,
            lyrics: lyrics,
            createdAt: DateTime.now(),
          );

          _songs.insert(0, newSong);
          playSong(newSong);
          _currentTabIndex = 4;
          notifyListeners();
          break;
      }
      notifyListeners();
    });
  }

  // ── Utilities ─────────────────────────────────────────────────────────────
  static String _toDisplayName(String username) {
    final match = RegExp(r'^([a-zA-Z]+?)(\d.*)$').firstMatch(username);
    if (match != null) {
      final letters = match.group(1)!;
      final rest = match.group(2)!;
      final cap =
          letters.isNotEmpty ? letters[0].toUpperCase() + letters.substring(1) : letters;
      return '$cap ${rest.toUpperCase()}';
    }
    return username.isNotEmpty
        ? username[0].toUpperCase() + username.substring(1)
        : username;
  }
}
