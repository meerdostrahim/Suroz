import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/waveform_visualizer.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  late AnimationController _vinylCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _slideAnim;

  double _progress = 0.22; // Simulated progress
  bool _isShuffle = false;
  bool _isRepeat = false;

  // Simulated timer for progress
  @override
  void initState() {
    super.initState();

    _vinylCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnim = CurvedAnimation(
      parent: _slideCtrl,
      curve: Curves.easeOutCubic,
    );

    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _vinylCtrl.dispose();
    _pulseCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Get a deterministic color from song id
  List<Color> _getGradientColors(String id) {
    final colors = [
      [const Color(0xFF1E3D59), const Color(0xFF0A1628)],
      [const Color(0xFF4A1942), const Color(0xFF1A0A1A)],
      [const Color(0xFF1A3A2A), const Color(0xFF0A1A10)],
      [const Color(0xFF3A2010), const Color(0xFF1A0A00)],
      [const Color(0xFF1A2A4A), const Color(0xFF060C1E)],
    ];
    final idx = id.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[idx];
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isRadio = appState.isRadioActive;
    final song = appState.currentSong;

    final title = isRadio
        ? appState.radioStationName
        : (song?.title ?? 'Unknown Track');
    final artist = isRadio
        ? '${appState.radioTuning['mood']} · ${appState.radioTuning['instrument']}'
        : (song?.artist ?? '');
    final tags = isRadio
        ? [
            appState.radioTuning['mood'] ?? '',
            appState.radioTuning['instrument'] ?? '',
          ]
        : (song?.tags ?? []);
    final duration = song?.duration ?? const Duration(minutes: 3, seconds: 30);
    final isSaved = song?.isSaved ?? false;

    final gradColors =
        _getGradientColors(song?.id ?? (isRadio ? 'radio' : 'default'));

    return AnimatedBuilder(
      animation: _slideAnim,
      builder: (_, child) => SlideTransition(
        position:
            Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          _slideAnim,
        ),
        child: child,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                gradColors[0],
                gradColors[1],
                AppTheme.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Top Bar ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textPrimary, size: 26),
                        ),
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Text('NOW PLAYING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 1.5,
                                )),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (song != null) appState.toggleSaveSong(song);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isSaved
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Scrollable Body Content ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),

                        // ── Vinyl / Album Art ───────────────────────────────────────
                        Center(
                          child: AnimatedBuilder(
                            animation: _vinylCtrl,
                            builder: (_, child) => Transform.rotate(
                              angle: appState.isPlaying
                                  ? _vinylCtrl.value * 2 * pi
                                  : 0,
                              child: AnimatedBuilder(
                                animation: _pulseCtrl,
                                builder: (_, child) => Container(
                                  width: 210,
                                  height: 210,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        gradColors[0].withValues(alpha: 0.8),
                                        AppTheme.cardBg,
                                        Colors.black87,
                                      ],
                                      stops: const [0.0, 0.55, 1.0],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: gradColors[0].withValues(
                                            alpha: 0.4 +
                                                0.2 * _pulseCtrl.value),
                                        blurRadius: 36 + 18 * _pulseCtrl.value,
                                        spreadRadius: -4,
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 26,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Vinyl rings
                                      ...List.generate(4, (i) {
                                        final r = 78.0 - i * 16.0;
                                        return Container(
                                          width: r * 2,
                                          height: r * 2,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.04 + i * 0.015),
                                              width: 1,
                                            ),
                                          ),
                                        );
                                      }),
                                      // Center hub
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppTheme.brandGradient,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primary
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 18,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isRadio
                                              ? Icons.radio_rounded
                                              : Icons.music_note_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Song Info ──────────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                artist,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Tags
                              Wrap(
                                spacing: 6,
                                children: tags
                                    .where((t) => t.isNotEmpty)
                                    .take(4)
                                    .map((t) => Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: AppTheme.primary
                                                  .withValues(alpha: 0.25),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(t,
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: AppTheme.primaryGlow,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Waveform ───────────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: WaveformVisualizer(
                            isPlaying: appState.isPlaying,
                            height: 42,
                            color: AppTheme.primary,
                            speedMultiplier: 0.8,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Progress Bar ───────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.primary,
                                  inactiveTrackColor:
                                      AppTheme.cardBorder.withValues(alpha: 0.6),
                                  thumbColor: AppTheme.primary,
                                  overlayColor:
                                      AppTheme.primary.withValues(alpha: 0.2),
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 7),
                                  trackHeight: 3.5,
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16),
                                ),
                                child: Slider(
                                  value: _progress,
                                  onChangeStart: (_) => {},
                                  onChanged: (v) =>
                                      setState(() => _progress = v),
                                  onChangeEnd: (_) => {},
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(Duration(
                                          seconds: (_progress *
                                                  duration.inSeconds)
                                              .toInt())),
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Controls ───────────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Shuffle
                              _ControlIcon(
                                icon: Icons.shuffle_rounded,
                                color: _isShuffle
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                                onTap: () {
                                  setState(() => _isShuffle = !_isShuffle);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_isShuffle
                                          ? 'Shuffle mode Enabled'
                                          : 'Shuffle mode Disabled'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                size: 22,
                              ),

                              // Previous
                              _ControlIcon(
                                icon: Icons.skip_previous_rounded,
                                onTap: () {
                                  setState(() => _progress = 0);
                                  final songs = appState.songs;
                                  if (songs.isNotEmpty) {
                                    final currentIndex = songs
                                        .indexWhere((s) => s.id == song?.id);
                                    final prevIndex = (currentIndex - 1 +
                                            songs.length) %
                                        songs.length;
                                    appState.playSong(songs[prevIndex]);
                                  }
                                },
                                size: 36,
                                color: AppTheme.textPrimary,
                              ),

                              // Play / Pause (primary)
                              GestureDetector(
                                onTap: appState.togglePlay,
                                child: AnimatedBuilder(
                                  animation: _pulseCtrl,
                                  builder: (_, child) => Container(
                                    width: 68,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.brandGradient,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary.withValues(
                                              alpha: 0.3 +
                                                  0.2 * _pulseCtrl.value),
                                          blurRadius:
                                              24 + 12 * _pulseCtrl.value,
                                          spreadRadius: -4,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      appState.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                  ),
                                ),
                              ),

                              // Next
                              _ControlIcon(
                                icon: Icons.skip_next_rounded,
                                onTap: () {
                                  setState(() => _progress = 0);
                                  final songs = appState.songs;
                                  if (songs.isNotEmpty) {
                                    if (_isShuffle) {
                                      final rand = ((songs.length *
                                                  (DateTime.now()
                                                          .millisecondsSinceEpoch %
                                                      100)) /
                                              100)
                                          .floor() %
                                          songs.length;
                                      appState.playSong(songs[rand]);
                                    } else {
                                      final currentIndex = songs
                                          .indexWhere((s) => s.id == song?.id);
                                      final nextIndex =
                                          (currentIndex + 1) % songs.length;
                                      appState.playSong(songs[nextIndex]);
                                    }
                                  }
                                },
                                size: 36,
                                color: AppTheme.textPrimary,
                              ),

                              // Repeat
                              _ControlIcon(
                                icon: Icons.repeat_rounded,
                                color: _isRepeat
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                                onTap: () {
                                  setState(() => _isRepeat = !_isRepeat);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_isRepeat
                                          ? 'Repeat mode Enabled'
                                          : 'Repeat mode Disabled'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                size: 22,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Bottom Actions ─────────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _ActionChip(
                                icon: Icons.share_rounded,
                                label: 'Share',
                                onTap: () => _showShareSheet(context, title),
                              ),
                              _ActionChip(
                                icon: Icons.queue_music_rounded,
                                label: 'Queue',
                                onTap: () =>
                                    _showQueueSheet(context, appState),
                              ),
                              _ActionChip(
                                icon: isSaved
                                    ? Icons.favorite_rounded
                                    : Icons.download_rounded,
                                label: isSaved ? 'Saved' : 'Save',
                                onTap: () {
                                  if (song != null) {
                                    appState.toggleSaveSong(song);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(song.isSaved
                                            ? 'Saved to Library'
                                            : 'Removed from Library'),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                              ),
                              _ActionChip(
                                icon: Icons.more_horiz_rounded,
                                label: 'More',
                                onTap: () => _showMoreOptionsSheet(
                                    context, appState, song),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShareSheet(BuildContext context, String trackTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Share Song',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('Sharing "$trackTitle"',
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _shareOption(ctx, Icons.link_rounded, 'Copy Link', () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Link copied to clipboard!'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating),
                  );
                }),
                _shareOption(ctx, Icons.message_rounded, 'Message', () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Opening Messages...'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating),
                  );
                }),
                _shareOption(ctx, Icons.send_rounded, 'Socials', () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Preparing story share...'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shareOption(
      BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.cardBorder, width: 0.8),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  void _showQueueSheet(BuildContext context, AppState appState) {
    final songs = appState.songs;
    final current = appState.currentSong;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.queue_music_rounded,
                    color: AppTheme.primaryGlow, size: 20),
                const SizedBox(width: 8),
                Text('Playback Queue',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: songs.length,
                itemBuilder: (_, i) {
                  final s = songs[i];
                  final isCurrent = s.id == current?.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppTheme.primary.withValues(alpha: 0.12)
                          : AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isCurrent ? AppTheme.primary : AppTheme.cardBorder,
                        width: 0.8,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        isCurrent
                            ? Icons.graphic_eq_rounded
                            : Icons.music_note_rounded,
                        color: isCurrent
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                        size: 20,
                      ),
                      title: Text(s.title,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      subtitle: Text(s.subtitle,
                          style: GoogleFonts.inter(
                              fontSize: 11, color: AppTheme.textSecondary)),
                      trailing: isCurrent
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text('NOW PLAYING',
                                  style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        appState.playSong(s);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptionsSheet(
      BuildContext context, AppState appState, Song? song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Track Options',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            ListTile(
              leading:
                  const Icon(Icons.playlist_add_rounded, color: AppTheme.primary),
              title: Text('Add to Playlist',
                  style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Added to My Favorites playlist!'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.equalizer_rounded, color: AppTheme.primary),
              title: Text('Audio Equalizer',
                  style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Equalizer set to Balochi Folk Bass Boost'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_rounded, color: AppTheme.primary),
              title: Text('Sleep Timer (30 mins)',
                  style: GoogleFonts.outfit(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sleep timer set for 30 minutes'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable control icon button ────────────────────────────────────────────
class _ControlIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;

  const _ControlIcon({
    required this.icon,
    required this.onTap,
    this.size = 24,
    this.color = AppTheme.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

// ── Bottom action chip ───────────────────────────────────────────────────────
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppTheme.cardBorder, width: 0.8),
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
