import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/waveform_visualizer.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen>
    with SingleTickerProviderStateMixin {
  late String _tunedMood;
  late String _tunedVoice;
  late String _tunedInstrument;
  late String _tunedRegion;
  bool _tuningExpanded = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  final List<String> _moods       = ['Calm', 'Energetic', 'Somber', 'Low', 'Bright'];
  final List<String> _voices      = ['Instrumental', 'Vocal'];
  final List<String> _instruments = ['Dambora', 'Suroz', 'Piano', 'Violin', 'Dholak', 'Flute', 'Guitar', 'Rubab', 'Harmonium'];
  final List<String> _regions     = ['Makkuran', 'Coastal', 'Highland'];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final t = Provider.of<AppState>(context, listen: false).radioTuning;
    _tunedMood       = t['mood']       ?? 'Calm';
    _tunedVoice      = t['voice']      ?? 'Instrumental';
    _tunedInstrument = t['instrument'] ?? 'Dambora';
    _tunedRegion     = t['region']     ?? 'Makkuran';
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  double get _speedMult {
    if (_tunedMood == 'Energetic') return 1.7;
    if (_tunedMood == 'Somber' || _tunedMood == 'Low') return 0.45;
    if (_tunedMood == 'Bright') return 1.3;
    return 0.9;
  }

  Color get _moodColor {
    switch (_tunedMood) {
      case 'Energetic': return const Color(0xFFFF5E3A);
      case 'Somber':    return const Color(0xFF6A7FDB);
      case 'Low':       return const Color(0xFF4ECDC4);
      case 'Bright':    return const Color(0xFFFFD166);
      default:          return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isPlaying = appState.isRadioActive && appState.isPlaying;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Status Bar ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? AppTheme.primary.withValues(alpha: 0.12)
                            : AppTheme.surfaceHigh,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isPlaying
                              ? AppTheme.primary.withValues(alpha: 0.3)
                              : AppTheme.cardBorder,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (_, _) => Container(
                              width: 6, height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPlaying ? AppTheme.primary : AppTheme.textMuted,
                                boxShadow: isPlaying
                                    ? [BoxShadow(
                                        color: AppTheme.primary
                                            .withValues(alpha: _pulseAnim.value * 0.7),
                                        blurRadius: 6,
                                      )]
                                    : [],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isPlaying ? 'LIVE' : 'OFFLINE',
                            style: GoogleFonts.outfit(
                              fontSize: 9, fontWeight: FontWeight.w800,
                              color: isPlaying ? AppTheme.primary : AppTheme.textMuted,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('ENDLESS AI STREAM',
                        style: GoogleFonts.outfit(
                          fontSize: 9, fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted, letterSpacing: 1.0,
                        )),
                  ],
                ),
              ),
            ),

            // ── Hero Station Card ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [
                        _moodColor.withValues(alpha: 0.18),
                        AppTheme.cardBg,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                        color: _moodColor.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Column(
                    children: [
                      // Top info
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appState.radioStationName,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppTheme.textPrimary,
                                )),
                            const SizedBox(height: 8),
                            Text(appState.radioStationDescription,
                                style: GoogleFonts.outfit(
                                  fontSize: 13, color: AppTheme.textSecondary, height: 1.5,
                                )),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 6, runSpacing: 6,
                              children: appState.radioTuning.values.map((v) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.cardBorder, width: 0.8),
                                  ),
                                  child: Text(v,
                                      style: GoogleFonts.outfit(
                                        fontSize: 11, fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      )),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Visualizer
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            color: AppTheme.background.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.graphic_eq_rounded,
                                        color: _moodColor, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_tunedMood == 'Energetic' ? '128' : '66'} BPM · $_tunedInstrument',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11, fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                WaveformVisualizer(
                                  isPlaying: isPlaying,
                                  height: 80,
                                  color: _moodColor,
                                  speedMultiplier: _speedMult,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Controls
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _PlayStationBtn(
                                isPlaying: isPlaying,
                                onTap: () {
                                  if (isPlaying) {
                                    appState.togglePlay();
                                  } else {
                                    appState.playRadio();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: _CaptureBtn(onTap: () {
                                appState.captureRadioClip();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppTheme.success, size: 16),
                                      const SizedBox(width: 8),
                                      Text('Captured! (−10 credits)',
                                          style: GoogleFonts.outfit(fontSize: 13)),
                                    ]),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Tune Section ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: GestureDetector(
                  onTap: () => setState(() => _tuningExpanded = !_tuningExpanded),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppTheme.card(),
                    child: Row(
                      children: [
                        Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              color: AppTheme.primary, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tune Your Sound',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700, fontSize: 15,
                                    color: AppTheme.textPrimary,
                                  )),
                              Text('$_tunedMood · $_tunedInstrument · $_tunedRegion',
                                  style: GoogleFonts.outfit(
                                      fontSize: 11, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: _tuningExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Expanded Tuning Panel ──────────────────────────────────────
            if (_tuningExpanded)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TuningRow('Mood', _moods, _tunedMood,
                            (v) => setState(() => _tunedMood = v)),
                        const SizedBox(height: 18),
                        _TuningRow('Voice', _voices, _tunedVoice,
                            (v) => setState(() => _tunedVoice = v)),
                        const SizedBox(height: 18),
                        _TuningRow('Instrument', _instruments, _tunedInstrument,
                            (v) => setState(() => _tunedInstrument = v)),
                        const SizedBox(height: 18),
                        _TuningRow('Region', _regions, _tunedRegion,
                            (v) => setState(() => _tunedRegion = v)),
                        const SizedBox(height: 24),
                        _ApplyTuneBtn(
                          onTap: () {
                            appState.tuneRadio(_tunedMood, _tunedVoice,
                                _tunedInstrument, _tunedRegion);
                            setState(() => _tuningExpanded = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Stream tuned to $_tunedMood · $_tunedInstrument',
                                    style: GoogleFonts.outfit(fontSize: 13)),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Tuning Row ──────────────────────────────────────────────────────────────
class _TuningRow extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _TuningRow(this.label, this.options, this.selected, this.onSelect);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary, letterSpacing: 0.8,
            )),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: options.map((opt) {
            final sel = opt == selected;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary.withValues(alpha: 0.12) : AppTheme.surfaceHigh,
                  border: Border.all(
                    color: sel ? AppTheme.primary : AppTheme.cardBorder,
                    width: sel ? 1.2 : 0.8,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(opt,
                    style: GoogleFonts.outfit(
                      fontSize: 12, fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? AppTheme.primary : AppTheme.textPrimary,
                    )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Play Button ────────────────────────────────────────────────────────────
class _PlayStationBtn extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayStationBtn({required this.isPlaying, required this.onTap});

  @override
  State<_PlayStationBtn> createState() => _PlayStationBtnState();
}

class _PlayStationBtnState extends State<_PlayStationBtn>
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
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    final isPlaying = widget.isPlaying;
    return GestureDetector(
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            gradient: isPlaying
                ? null
                : const LinearGradient(
                    colors: [Color(0xFFFF8C3A), Color(0xFFE8701A), Color(0xFFB84F10)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isPlaying ? AppTheme.surfaceHigh : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? AppTheme.cardBorder
                  : AppTheme.primary.withValues(alpha: 0.5),
              width: isPlaying ? 0.8 : 1.2,
            ),
            boxShadow: isPlaying
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.45),
                      blurRadius: 22,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: AppTheme.primaryGlow.withValues(alpha: 0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isPlaying
                      ? AppTheme.textMuted.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: isPlaying ? AppTheme.textSecondary : Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPlaying ? 'Pause' : 'Play Station',
                    style: GoogleFonts.outfit(
                      color: isPlaying ? AppTheme.textPrimary : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.1,
                    ),
                  ),
                  if (!isPlaying)
                    Text(
                      'AI · Live Stream',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Capture Button ─────────────────────────────────────────────────────────
class _CaptureBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _CaptureBtn({required this.onTap});

  @override
  State<_CaptureBtn> createState() => _CaptureBtnState();
}

class _CaptureBtnState extends State<_CaptureBtn>
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
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: AppTheme.surfaceHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.cardBorder,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bookmark_add_rounded,
                  color: AppTheme.textPrimary,
                  size: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Capture',
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.1,
                ),
              ),
              Text(
                '30s clip',
                style: GoogleFonts.outfit(
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Apply & Tune Button ─────────────────────────────────────────────────────
class _ApplyTuneBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _ApplyTuneBtn({required this.onTap});

  @override
  State<_ApplyTuneBtn> createState() => _ApplyTuneBtnState();
}

class _ApplyTuneBtnState extends State<_ApplyTuneBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8C3A), Color(0xFFE8701A), Color(0xFFB84F10)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.55),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.40),
                blurRadius: 24,
                offset: const Offset(0, 7),
                spreadRadius: -3,
              ),
              BoxShadow(
                color: AppTheme.primaryGlow.withValues(alpha: 0.18),
                blurRadius: 40,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Apply & Tune Stream',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Text(
                    'Refresh AI radio with your settings',
                    style: GoogleFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
