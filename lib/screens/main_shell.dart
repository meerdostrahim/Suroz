import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/waveform_visualizer.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
import 'create_screen.dart';
import 'radio_screen.dart';
import 'profile_screen.dart';
import 'now_playing_screen.dart';


// Tab index mapping:
// 0 = Home | 1 = Search | 2 = Create | 3 = Studio | 4 = Profile

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final List<Widget> _screens = const [
    HomeScreen(),
    DiscoverScreen(),
    CreateScreen(),
    RadioScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final tabIndex = appState.currentTabIndex;
    final hasPlayer = appState.isPlaying ||
        appState.currentSong != null ||
        appState.isRadioActive;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: tabIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: hasPlayer
                ? _MiniPlayer(appState: appState)
                : const SizedBox.shrink(),
          ),
          _PremiumNavBar(
            currentIndex: tabIndex,
            onTap: appState.setTabIndex,
          ),
        ],
      ),
    );
  }
}

// ── Premium Floating Curved Nav Bar ───────────────────────────────────────────
class _PremiumNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 14,
        bottom: bottomPadding > 0 ? bottomPadding : 12,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Floating bar container
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppTheme.cardBorder,
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 30,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Tab 0: Home
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                ),
                // Tab 1: Search
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.search_rounded,
                    activeIcon: Icons.search_rounded,
                    label: 'Search',
                    isSelected: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),
                ),
                // Tab 2 Spacer for Center Create Button
                const Expanded(
                  child: SizedBox.shrink(),
                ),
                // Tab 3: Studio
                Expanded(
                  child: _NavBarItem(
                    icon: Icons.graphic_eq_outlined,
                    activeIcon: Icons.graphic_eq_rounded,
                    label: 'Studio',
                    isSelected: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ),
                // Tab 4: Profile Avatar (opens account menu overlay)
                Expanded(
                  child: _ProfileAvatarButton(
                    isSelected: currentIndex == 4,
                    onProfileTap: () => onTap(4),
                  ),
                ),
              ],
            ),
          ),

          // Center Floating Circular Create Button (+)
          Positioned(
            top: -18,
            child: _CenterCreateFab(
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Regular Nav Item with Active Dot Indicator ─────────────────────────────────
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            size: 22,
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          ),
          const SizedBox(height: 3),
          // Active dot indicator (matching user screenshot layout)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 5 : 0,
            height: isSelected ? 5 : 0,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: isSelected ? 2 : 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Center Floating Create FAB (+) ─────────────────────────────────────────────
class _CenterCreateFab extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterCreateFab({required this.isSelected, required this.onTap});

  @override
  State<_CenterCreateFab> createState() => _CenterCreateFabState();
}

class _CenterCreateFabState extends State<_CenterCreateFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C3A), Color(0xFFE8701A), Color(0xFFB84F10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppTheme.primaryGlow.withValues(alpha: 0.6),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.55),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: AppTheme.primaryGlow.withValues(alpha: 0.25),
                    blurRadius: 36,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini Player ────────────────────────────────────────────────────────────────
class _MiniPlayer extends StatelessWidget {
  final AppState appState;
  const _MiniPlayer({required this.appState});

  @override
  Widget build(BuildContext context) {
    final isRadio = appState.isRadioActive;
    final song = appState.currentSong;
    final title = isRadio
        ? appState.radioStationName
        : (song?.title ?? 'Unknown Track');
    final subtitle = isRadio
        ? '${appState.radioTuning['mood']} · ${appState.radioTuning['instrument']}'
        : (song?.artist ?? '');

    return GestureDetector(
      onTap: () {
        if (isRadio) {
          appState.setTabIndex(3);
        } else {
          // Open full Now Playing screen
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const NowPlayingScreen(),
              transitionDuration: const Duration(milliseconds: 380),
              reverseTransitionDuration: const Duration(milliseconds: 280),
              transitionsBuilder: (_, animation, _, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: child,
                );
              },
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.22), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                  isRadio ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                  color: Colors.white,
                  size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis),
                  Text(subtitle,
                      style: GoogleFonts.outfit(
                          fontSize: 10, color: AppTheme.textSecondary),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 44,
              child: WaveformVisualizer(
                  isPlaying: appState.isPlaying,
                  height: 26,
                  color: AppTheme.primary,
                  speedMultiplier: 1.2),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: appState.togglePlay,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: AppTheme.primary, shape: BoxShape.circle),
                child: Icon(
                  appState.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: appState.stopPlayback,
              child: const Icon(Icons.close_rounded,
                  color: AppTheme.textSecondary, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Avatar Button ──────────────────────────────────────────────────────
class _ProfileAvatarButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onProfileTap;

  const _ProfileAvatarButton({
    required this.isSelected,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser ?? 'User';
    final initial = user.isNotEmpty ? user[0].toUpperCase() : 'U';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onProfileTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8C3A), Color(0xFFB84F10)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.cardBorder,
                width: isSelected ? 2.0 : 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.45),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 5 : 0,
            height: isSelected ? 5 : 0,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: isSelected ? 2 : 4),
          Text(
            'Profile',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
