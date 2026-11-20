import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/waveform_visualizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Premium Header ───────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context, appState)),

          // ── Stats Row ────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildStatsRow(context, appState)),

          // ── Hero Launchpad ───────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeroBanner(context, appState)),

          // ── Section: Continue ─────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildSectionLabel(context, 'CONTINUE FROM CAPTURE')),
          SliverToBoxAdapter(child: _buildCaptureCard(context, appState)),

          // ── Section: Quick Actions ────────────────────────────────────────
          SliverToBoxAdapter(child: _buildSectionLabel(context, 'QUICK ACTIONS')),
          SliverToBoxAdapter(child: _buildQuickActions(context, appState)),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Text('SOROZ',
                  style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary, letterSpacing: 2.5,
                  )),
            ],
          ),
          const Spacer(),
          // Credits pill
          _CreditsBadge(credits: appState.credits),
          const SizedBox(width: 12),
          // Avatar
          GestureDetector(
            onTap: () {
              appState.setTabIndex(4);
            },
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A7A5E), Color(0xFF0E4F3E)],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.cardBorder, width: 1.5),
              ),
              child: Center(
                child: Text(
                  appState.currentUser != null && appState.currentUser!.isNotEmpty
                      ? appState.currentUser![0].toUpperCase()
                      : 'J',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────
  Widget _buildStatsRow(BuildContext context, AppState appState) {
    final stats = [
      ('${appState.songs.length}', 'Songs', Icons.library_music_outlined),
      ('${appState.credits}', 'Credits', Icons.bolt_rounded),
      ('${appState.drafts.length}', 'Drafts', Icons.edit_note_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: i > 0 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
              decoration: AppTheme.card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.$1,
                          style: GoogleFonts.outfit(
                            fontSize: 26, fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          )),
                      Icon(s.$3, color: AppTheme.primary, size: 18),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(s.$2,
                      style: GoogleFonts.outfit(
                        fontSize: 11, fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Hero Banner ────────────────────────────────────────────────────────────
  Widget _buildHeroBanner(BuildContext context, AppState appState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF1F0D00), Color(0xFF140A00), Color(0xFF0A0A0C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.20), width: 1),
        ),
        child: Stack(
          children: [
            // Background glow orb
            Positioned(
              top: -30, right: -20,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppTheme.primary.withValues(alpha: 0.14),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppTheme.primaryGlow, size: 11),
                        const SizedBox(width: 5),
                        Text('STUDIO LAUNCHPAD',
                            style: GoogleFonts.outfit(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGlow, letterSpacing: 1.2,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Create songs from\nlyrics & moments.',
                      style: GoogleFonts.outfit(
                        fontSize: 24, fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary, height: 1.2,
                        letterSpacing: -0.5,
                      )),
                  const SizedBox(height: 8),
                  Text(
                    'Start with words, tune a live stream, or capture a drift.',
                    style: GoogleFonts.outfit(
                      fontSize: 13, color: AppTheme.textSecondary, height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      _PrimaryButton(
                        label: 'Create Song',
                        icon: Icons.add_rounded,
                        onTap: () => appState.setTabIndex(2),
                      ),
                      const SizedBox(width: 12),
                      _TextButton(
                        label: 'Open Studio',
                        onTap: () => appState.setTabIndex(3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(label,
          style: GoogleFonts.outfit(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary, letterSpacing: 1.4,
          )),
    );
  }

  // ── Capture Card ───────────────────────────────────────────────────────────
  Widget _buildCaptureCard(BuildContext context, AppState appState) {
    final isPlaying = appState.isRadioActive && appState.isPlaying;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Container(
        decoration: AppTheme.card(glowing: isPlaying),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.radio_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Desert Night Radio',
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700, fontSize: 15,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      Text('30s captured · Suroz stream',
                          style: GoogleFonts.outfit(
                              fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (isPlaying) {
                      appState.togglePlay();
                    } else {
                      appState.tuneRadio('Calm', 'Instrumental', 'Suroz', 'Makkuran');
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isPlaying ? AppTheme.primary : AppTheme.surfaceHigh,
                      shape: BoxShape.circle,
                      boxShadow: isPlaying
                          ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4),
                              blurRadius: 12, offset: const Offset(0, 3))]
                          : [],
                    ),
                    child: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white, size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            WaveformVisualizer(
                isPlaying: isPlaying, height: 44, speedMultiplier: 0.8),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context, AppState appState) {
    final actions = [
      (Icons.compass_calibration_outlined, 'Discover', 'Find community drifts', 1),
      (Icons.folder_copy_outlined, 'My Library', 'View your tracks', 4),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        children: actions.asMap().entries.map((entry) {
          final i = entry.key;
          final a = entry.value;
          return Expanded(
            child: GestureDetector(
              onTap: () => appState.setTabIndex(a.$4),
              child: Container(
                margin: EdgeInsets.only(left: i > 0 ? 10 : 0),
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a.$1, color: AppTheme.primary, size: 18),
                    ),
                    const SizedBox(height: 12),
                    Text(a.$2,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700, fontSize: 13,
                            color: AppTheme.textPrimary)),
                    const SizedBox(height: 2),
                    Text(a.$3,
                        style: GoogleFonts.outfit(
                            fontSize: 11, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Shared Button Widgets ──────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppTheme.brandGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.35),
              blurRadius: 16, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 7),
            Text(label,
                style: GoogleFonts.outfit(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.cardBorder, width: 0.8),
        ),
        child: Text(label,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13,
            )),
      ),
    );
  }
}

class _CreditsBadge extends StatelessWidget {
  final int credits;
  const _CreditsBadge({required this.credits});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 14),
          const SizedBox(width: 4),
          Text('$credits cr',
              style: GoogleFonts.outfit(
                color: AppTheme.primary, fontWeight: FontWeight.w700, fontSize: 12,
              )),
        ],
      ),
    );
  }
}
