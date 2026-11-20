import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _lyricsController = TextEditingController();
  bool _isAdvanced = false;
  String _selectedLang = 'Balochi';
  bool _isInstrumental = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  bool _showOptions = false;
  bool _showInspire = false;

  late AnimationController _optionsAnim;

  // Simple mode selections
  String _selectedGenre = 'Soroz';
  final Set<String> _selectedInstruments = {'Dambura'};
  String _selectedVocalStyle = 'Male';
  bool _customAiVoice = false;

  // Advanced mode selections
  String _selectedTempo = 'Moderate (90 BPM)';
  String _selectedMood = 'Mystical';
  String _selectedEnergy = 'Moderate';
  String _selectedDuration = '3:00';
  String _selectedVoice = 'Solo Male';
  String _selectedIntensity = 'Balanced';
  String _selectedCreativity = 'Balanced';
  String _selectedVisibility = 'Public';

  final Map<String, Map<String, dynamic>> _languageData = {
    'Balochi': {
      'native': 'بلوجي',
      'icon': Icons.music_note_rounded,
      'isRtl': true,
      'hint': 'Create a romantic Balochi song\nabout the sunset in Gwadar...',
      'example': 'Create a romantic Balochi song about the sunset in Gwadar.',
      'suggestions': [
        'مکران ءِ شادمانی و دهل ریتم',
        'ارامیں سروز و دمبوره زیمر',
        'بلوچی کوہنیں زهروک و ساز',
        'کوستل شام ءِ وشیں ملودی',
        'بلوچی گیت گون دمبوره',
      ],
    },
    'Urdu': {
      'native': 'اردو',
      'icon': Icons.queue_music_rounded,
      'isRtl': true,
      'hint': 'دمبورہ اور سروز کی دھن کے ساتھ خوبصورت گانا...',
      'example': 'گوادر کی شام پر ایک خوبصورت بلوچی گانا بنائیں۔',
      'suggestions': [
        'سروز اور دمبورہ کی پرسکون دھن',
        'مکرانی شادی کا روایتی گیت',
        'آہستہ اور روح پرور بلوچی ساز',
        'کلاسک زہروک اور جدید گیت',
        'بلوچی لوک موسیقی کی دھن',
      ],
    },
    'English': {
      'native': 'English',
      'icon': Icons.language_rounded,
      'isRtl': false,
      'hint': 'Create a romantic Balochi song\nabout the sunset in Gwadar...',
      'example': 'Create a romantic Balochi song about the sunset in Gwadar.',
      'suggestions': [
        'Celebration with Duholl rhythm',
        'Atmospheric Balochi guitars',
        'Slow ambient Suroz drone',
        'Sweet coastal melody',
        'Makkuran wedding loop',
      ],
    },
    'Arabic': {
      'native': 'عربي',
      'icon': Icons.graphic_eq_rounded,
      'isRtl': true,
      'hint': 'أغنية احتفالية بالإيقاع البلوشي والدمبورة...',
      'example': 'أنشئ أغنية بلوشية رومانسية عن غروب الشمس في جوادر.',
      'suggestions': [
        'نغمة السروز الهادئة والتراثية',
        'إيقاع الدهل للاحتفالات البلوشية',
        'لحن بلوشي قديم ومؤثر',
        'موسيقى التراث البلوشي الفلكلورية',
        'عزف دمبورة مع إيقاع ساحلي',
      ],
    },
    'Brahui': {
      'native': 'براهوئي',
      'icon': Icons.library_music_rounded,
      'isRtl': true,
      'hint': 'دمبوره و سروز تون براهوئی زیمل...',
      'example': 'گوادر نا شام بارا یک وشیں براهوئی زیمر سازاں کن.',
      'suggestions': [
        'براهوئی دود و ربیدگ نا زیمل',
        'ارام انگا سروز و دمبوره تلم',
        'مکرانی سیر نا وشیں زیمر',
        'براهوئی لوک ساز و ریتم',
        'دمبوره تون شادمانی نا زیمل',
      ],
    },
  };

  List<Map<String, dynamic>> get _languages => _languageData.entries
      .map((e) => {
            'name': e.key,
            'native': e.value['native'] as String,
            'icon': e.value['icon'] as IconData,
          })
      .toList();

  String get _currentHintText =>
      _languageData[_selectedLang]?['hint'] ??
      'Create a romantic Balochi song\nabout the sunset in Gwadar...';

  String get _currentExample =>
      _languageData[_selectedLang]?['example'] ??
      'Create a romantic Balochi song about the sunset in Gwadar.';

  List<String> get _currentSuggestions =>
      List<String>.from(_languageData[_selectedLang]?['suggestions'] ?? []);

  bool get _isCurrentRtl =>
      _languageData[_selectedLang]?['isRtl'] == true;

  // Inspire Me moods
  final List<Map<String, dynamic>> _inspireMoods = [
    {'label': 'Romantic',    'icon': Icons.favorite_rounded,       'color': const Color(0xFFFF4B4B), 'prompt': 'Create a romantic love song with soft melody and heartfelt emotions'},
    {'label': 'Traditional', 'icon': Icons.music_note_rounded,     'color': const Color(0xFFE8701A), 'prompt': 'Create a traditional Balochi song with authentic cultural instruments'},
    {'label': 'Wedding',     'icon': Icons.celebration_rounded,    'color': const Color(0xFFFFB74D), 'prompt': 'Create a joyful Balochi wedding celebration song with Dambura rhythm'},
    {'label': 'Sad',         'icon': Icons.water_drop_rounded,     'color': const Color(0xFF64B5F6), 'prompt': 'Create a melancholic and emotional song expressing deep sadness'},
    {'label': 'Sufi',        'icon': Icons.blur_circular_rounded,  'color': const Color(0xFFBA68C8), 'prompt': 'Create a spiritual Sufi song with devotional lyrics and mystic melody'},
    {'label': 'Nature',      'icon': Icons.eco_rounded,            'color': const Color(0xFF81C784), 'prompt': 'Create a peaceful nature-inspired song about mountains and rivers'},
    {'label': 'Travel',      'icon': Icons.explore_rounded,        'color': const Color(0xFF4DD0E1), 'prompt': 'Create an upbeat travel song about journeys and new adventures'},
    {'label': 'Cultural',    'icon': Icons.account_balance_rounded,'color': const Color(0xFFFF8A65), 'prompt': 'Create a song celebrating Balochi culture, heritage and traditions'},
  ];

  // Genre options (Simple mode)
  final List<Map<String, dynamic>> _genres = [
    {'name': 'Soroz',   'icon': Icons.piano_rounded},
    {'name': 'Liko',    'icon': Icons.surround_sound_rounded},
    {'name': 'Sufi',    'icon': Icons.blur_circular_rounded},
    {'name': 'Wedding', 'icon': Icons.celebration_rounded},
    {'name': 'Pop',     'icon': Icons.mic_external_on_rounded},
    {'name': 'Folk',    'icon': Icons.library_music_rounded},
    {'name': 'Modern',  'icon': Icons.graphic_eq_rounded},
    {'name': 'Custom',  'icon': Icons.tune_rounded},
  ];

  // Traditional & Modern instruments (multi-select)
  final List<Map<String, dynamic>> _traditionalInstruments = [
    {'name': 'Soroz',   'icon': Icons.music_note_rounded},
    {'name': 'Benju',   'icon': Icons.piano_rounded},
    {'name': 'Rabab',   'icon': Icons.audiotrack_rounded},
    {'name': 'Dambura', 'icon': Icons.queue_music_rounded},
    {'name': 'Doneli',  'icon': Icons.multitrack_audio_rounded},
  ];
  final List<Map<String, dynamic>> _modernInstruments = [
    {'name': 'Guitar', 'icon': Icons.music_note_rounded},
    {'name': 'Piano',  'icon': Icons.piano_rounded},
    {'name': 'Bass',   'icon': Icons.subtitles_rounded},
    {'name': 'Drums',  'icon': Icons.radio_rounded},
    {'name': 'Synth',  'icon': Icons.equalizer_rounded},
  ];

  // Vocal styles
  final List<Map<String, dynamic>> _vocalStyles = [
    {'label': 'Male',       'icon': Icons.person_rounded},
    {'label': 'Female',     'icon': Icons.person_outline_rounded},
    {'label': 'Traditional','icon': Icons.account_balance_rounded},
    {'label': 'Modern',     'icon': Icons.auto_awesome_rounded},
    {'label': 'Soft',       'icon': Icons.spa_rounded},
    {'label': 'Powerful',   'icon': Icons.bolt_rounded},
    {'label': 'Emotional',  'icon': Icons.favorite_border_rounded},
  ];

  // Advanced mode lists
  final List<String> _tempos = [
    'Slow (60 BPM)', 'Moderate (90 BPM)', 'Fast (120 BPM)', 'Upbeat (140 BPM)',
  ];
  final List<String> _moods = [
    'Mystical', 'Melancholic', 'Joyful', 'Energetic', 'Romantic', 'Nostalgic', 'Spiritual',
  ];
  final List<String> _energies = [
    'Subtle / Chill', 'Moderate', 'High Energy', 'Maximum',
  ];
  final List<String> _durations = [
    '1:00', '2:00', '3:00', '4:00', '5:00',
  ];
  final List<String> _voices = [
    'Solo Male', 'Solo Female', 'Duet', 'Choir', 'Chanting', 'Soft', 'Emotional', 'Instrumental',
  ];
  final List<String> _intensities = [
    'Subtle Background', 'Balanced', 'Heavy / Solo Focus',
  ];
  final List<String> _creativities = [
    'Classic / Strict', 'Balanced', 'Experimental', 'Wild AI Freedom',
  ];

  @override
  void initState() {
    super.initState();
    _optionsAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    _lyricsController.dispose();
    _optionsAnim.dispose();
    super.dispose();
  }

  void _toggleOptions() {
    setState(() {
      if (!_isAdvanced) {
        _isAdvanced = true;
        _showOptions = true;
      } else {
        _showOptions = !_showOptions;
      }
    });
    if (_showOptions) {
      _optionsAnim.forward();
    } else {
      _optionsAnim.reverse();
    }
  }

  void _toggleRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        final duration = _recordingSeconds;
        _recordingSeconds = 0;
        if (duration > 0) {
          _lyricsController.text = '[Voice Melody — ${duration}s recorded]';
          _isInstrumental = false;
          if (_selectedVoice == 'Instrumental') _selectedVoice = 'Solo Male';
        }
      });
    } else {
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted || !_isRecording) return false;
        setState(() => _recordingSeconds++);
        return _isRecording;
      });
    }
  }

  void _showLyricsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Song Lyrics',
                    style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: AppTheme.textPrimary)),
                const Spacer(),
                StatefulBuilder(
                  builder: (ctx2, setSheetState) {
                    return GestureDetector(
                      onTap: () {
                        _toggleRecording();
                        setSheetState(() {});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? const Color(0xFFFF3B30).withValues(alpha: 0.15)
                              : AppTheme.surfaceHigh,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isRecording
                                ? const Color(0xFFFF3B30)
                                : AppTheme.cardBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: _isRecording
                              ? const Color(0xFFFF3B30)
                              : AppTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                ),
              ],
            ),
            StatefulBuilder(
              builder: (ctx2, setSheetState) {
                if (!_isRecording) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                        width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record,
                          color: Color(0xFFFF3B30), size: 10),
                      const SizedBox(width: 8),
                      Text('Recording melody...',
                          style: GoogleFonts.outfit(
                              color: const Color(0xFFFF3B30),
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Text(
                        '${(_recordingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}',
                        style: GoogleFonts.outfit(
                            color: const Color(0xFFFF3B30),
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lyricsController,
              maxLines: 8,
              style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary, fontSize: 14, height: 1.6),
              decoration: InputDecoration(
                hintText: 'Write your lyrics, poetry or melody here...',
                hintStyle: GoogleFonts.outfit(
                    color: AppTheme.textMuted, fontSize: 13),
                filled: true,
                fillColor: AppTheme.cardBg,
                contentPadding: const EdgeInsets.all(18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AppTheme.cardBorder, width: 0.8)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AppTheme.primary, width: 1.5)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AppTheme.cardBorder, width: 0.8)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_isRecording) _toggleRecording();
                  if (_lyricsController.text.trim().isNotEmpty) {
                    setState(() {
                      _isInstrumental = false;
                      if (_selectedVoice == 'Instrumental') {
                        _selectedVoice = 'Solo Male';
                      }
                    });
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text('Save Lyrics',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildChipSelector({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        itemBuilder: (_, i) {
          final opt = options[i];
          final sel = opt == selected;
          return GestureDetector(
            onTap: () => onSelect(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: sel
                    ? AppTheme.primary.withValues(alpha: 0.14)
                    : AppTheme.surfaceHigh,
                border: Border.all(
                  color: sel ? AppTheme.primary : AppTheme.cardBorder,
                  width: sel ? 1.2 : 0.8,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          blurRadius: 8, spreadRadius: -2,
                        ),
                      ]
                    : [],
              ),
              child: Text(
                opt,
                style: GoogleFonts.outfit(
                  color: sel ? AppTheme.primary : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter _sectionLabel(String label) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.isGenerating) {
      return _buildGeneratingScreen(context, appState);
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge row + Simple/Advanced toggle (overflow-proof)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        // AI badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  color: AppTheme.primaryGlow, size: 12),
                              const SizedBox(width: 5),
                              Text('AI Music Creation',
                                  style: GoogleFonts.outfit(
                                    color: AppTheme.primaryGlow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.4,
                                  )),
                            ],
                          ),
                        ),
                        // Simple / Advanced toggle — top right
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.cardBorder, width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ModeTab('Simple', !_isAdvanced,
                                  () => setState(() => _isAdvanced = false)),
                              _ModeTab('Advanced', _isAdvanced,
                                  () => setState(() => _isAdvanced = true)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create Your Song',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Describe the music you want to create.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Language Selector ──────────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _languages.length,
                  itemBuilder: (_, i) {
                    final lang = _languages[i];
                    final sel = _selectedLang == lang['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedLang = lang['name']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppTheme.primary.withValues(alpha: 0.12)
                              : AppTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel
                                ? AppTheme.primary
                                : AppTheme.cardBorder,
                            width: sel ? 1.2 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(lang['icon'] as IconData,
                                color: sel
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                                size: 16),
                            const SizedBox(width: 6),
                            Text(
                              lang['native'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: sel
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Prompt Box ────────────────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _descController.text.isNotEmpty
                          ? AppTheme.primary.withValues(alpha: 0.5)
                          : AppTheme.cardBorder,
                      width: _descController.text.isNotEmpty ? 1.2 : 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                      if (_descController.text.isNotEmpty)
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          blurRadius: 24,
                          spreadRadius: -4,
                        ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _descController,
                        maxLines: 6,
                        maxLength: 300,
                        textDirection: _isCurrentRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        onChanged: (_) => setState(() {}),
                        style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          height: 1.65,
                        ),
                        decoration: InputDecoration(
                          hintText: _currentHintText,
                          hintTextDirection: _isCurrentRtl
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          hintStyle: GoogleFonts.inter(
                            color: AppTheme.textMuted,
                            fontSize: 15,
                            height: 1.65,
                          ),
                          counterStyle: GoogleFonts.inter(
                              color: AppTheme.textMuted, fontSize: 10),
                          filled: false,
                          contentPadding: const EdgeInsets.fromLTRB(
                              20, 20, 20, 8),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                      // Bottom row with example & actions (overflow-proof)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // Add Lyrics
                              GestureDetector(
                                onTap: _showLyricsSheet,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _lyricsController.text.isNotEmpty
                                        ? AppTheme.primary.withValues(alpha: 0.12)
                                        : AppTheme.surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _lyricsController.text.isNotEmpty
                                          ? AppTheme.primary
                                          : AppTheme.cardBorder,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _lyricsController.text.isNotEmpty
                                            ? Icons.check_circle_rounded
                                            : Icons.add_rounded,
                                        color: _lyricsController.text.isNotEmpty
                                            ? AppTheme.primary
                                            : AppTheme.textSecondary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _lyricsController.text.isNotEmpty
                                            ? 'Lyrics Added'
                                            : 'Add Lyrics',
                                        style: GoogleFonts.outfit(
                                          color: _lyricsController.text.isNotEmpty
                                              ? AppTheme.primary
                                              : AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Mic record
                              GestureDetector(
                                onTap: _toggleRecording,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _isRecording
                                        ? const Color(0xFFFF3B30)
                                            .withValues(alpha: 0.14)
                                        : AppTheme.surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _isRecording
                                          ? const Color(0xFFFF3B30)
                                          : AppTheme.cardBorder,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isRecording
                                            ? Icons.stop_rounded
                                            : Icons.mic_rounded,
                                        color: _isRecording
                                            ? const Color(0xFFFF3B30)
                                            : AppTheme.textSecondary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        _isRecording
                                            ? '${(_recordingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}'
                                            : 'Record',
                                        style: GoogleFonts.outfit(
                                          color: _isRecording
                                              ? const Color(0xFFFF3B30)
                                              : AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Instrumental toggle chip
                              GestureDetector(
                                onTap: () => setState(() {
                                  _isInstrumental = !_isInstrumental;
                                  if (_isInstrumental) {
                                    _lyricsController.clear();
                                    _selectedVoice = 'Instrumental';
                                  } else if (_selectedVoice == 'Instrumental') {
                                    _selectedVoice = 'Solo Male';
                                  }
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _isInstrumental
                                        ? AppTheme.primary.withValues(alpha: 0.12)
                                        : AppTheme.surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _isInstrumental
                                          ? AppTheme.primary
                                          : AppTheme.cardBorder,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.piano_rounded,
                                        color: _isInstrumental
                                            ? AppTheme.primary
                                            : AppTheme.textSecondary,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Instrumental',
                                        style: GoogleFonts.outfit(
                                          color: _isInstrumental
                                              ? AppTheme.primary
                                              : AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Recording banner ─────────────────────────────────────────────
            if (_isRecording)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3B30).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                          width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record,
                            color: Color(0xFFFF3B30), size: 10),
                        const SizedBox(width: 8),
                        Text('Recording your melody...',
                            style: GoogleFonts.outfit(
                                color: const Color(0xFFFF3B30),
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(
                          '${(_recordingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}',
                          style: GoogleFonts.outfit(
                              color: const Color(0xFFFF3B30),
                              fontSize: 14,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _toggleRecording,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3B30)
                                  .withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.stop_rounded,
                                color: Color(0xFFFF3B30), size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Example hint ──────────────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() {
                        _descController.text = _currentExample;
                        _isAdvanced = false;
                      }),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppTheme.cardBorder, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_rounded,
                                color: AppTheme.primaryGlow, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _currentExample,
                                textDirection: _isCurrentRtl
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                style: GoogleFonts.inter(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                color: AppTheme.textMuted, size: 11),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Inspire Me + Suggestion row ───────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Inspire Me button
                    GestureDetector(
                      onTap: () => setState(() => _showInspire = !_showInspire),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          gradient: _showInspire ? AppTheme.brandGradient : null,
                          color: _showInspire ? null : AppTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showInspire
                                ? Colors.transparent
                                : AppTheme.cardBorder,
                            width: 0.8,
                          ),
                          boxShadow: _showInspire
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: -2,
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_rounded,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Inspire Me',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Scrollable suggestion chips
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _currentSuggestions.length,
                          itemBuilder: (_, i) {
                            final sug = _currentSuggestions[i];
                            return GestureDetector(
                              onTap: () => setState(() {
                                _descController.text = sug;
                                _isAdvanced = false;
                              }),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceHigh,
                                  border: Border.all(
                                      color: AppTheme.cardBorder, width: 0.8),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  sug,
                                  textDirection: _isCurrentRtl
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  style: GoogleFonts.outfit(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Inspire Me expanded panel ─────────────────────────────────────
            if (_showInspire) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _inspireMoods.map((mood) {
                      return GestureDetector(
                        onTap: () => setState(() {
                          _descController.text = mood['prompt']!;
                          _showInspire = false;
                          _isAdvanced = false;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.25),
                                width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(mood['icon'] as IconData,
                                  color: mood['color'] as Color, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                mood['label'] as String,
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            // ── Customize Options Toggle ───────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleOptions,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _showOptions
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : AppTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showOptions
                                ? AppTheme.primary.withValues(alpha: 0.4)
                                : AppTheme.cardBorder,
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune_rounded,
                                color: _showOptions
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                                size: 16),
                            const SizedBox(width: 8),
                            Text('Music Style',
                                style: GoogleFonts.outfit(
                                    color: _showOptions
                                        ? AppTheme.primary
                                        : AppTheme.textSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(width: 6),
                            AnimatedRotation(
                              turns: _showOptions ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              child: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: _showOptions
                                      ? AppTheme.primary
                                      : AppTheme.textSecondary,
                                  size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Cost badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppTheme.cardBorder, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: AppTheme.primaryGlow, size: 13),
                          const SizedBox(width: 3),
                          Text('${_isAdvanced ? 30 : 20} cr',
                              style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Expandable Options ─────────────────────────────────────────────
            if (_showOptions) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              if (!_isAdvanced) ...[ // ── SIMPLE MODE ──────────────────────────

                // Instrument Selection (multi-select, grouped)
                _sectionLabel('INSTRUMENTS'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Traditional group
                        Row(
                          children: [
                            const Icon(Icons.music_note_rounded,
                                color: AppTheme.primaryGlow, size: 12),
                            const SizedBox(width: 5),
                            Text('Traditional',
                                style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryGlow,
                                    letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _traditionalInstruments.map((inst) {
                            final sel =
                                _selectedInstruments.contains(inst['name']);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (sel) {
                                  _selectedInstruments.remove(inst['name']);
                                } else {
                                  _selectedInstruments.add(inst['name']!);
                                }
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppTheme.primary
                                          .withValues(alpha: 0.14)
                                      : AppTheme.surfaceHigh,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sel
                                        ? AppTheme.primary
                                        : AppTheme.cardBorder,
                                    width: sel ? 1.2 : 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(inst['icon'] as IconData,
                                        color: sel
                                            ? AppTheme.primary
                                            : AppTheme.textSecondary,
                                        size: 15),
                                    const SizedBox(width: 6),
                                    Text(inst['name'] as String,
                                        style: GoogleFonts.outfit(
                                          color: sel
                                              ? AppTheme.primary
                                              : AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: sel
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        )),
                                    if (sel) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppTheme.primary, size: 13),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        // Modern group
                        Row(
                          children: [
                            const Icon(Icons.electric_bolt_rounded,
                                color: AppTheme.textSecondary, size: 12),
                            const SizedBox(width: 5),
                            Text('Modern',
                                style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSecondary,
                                    letterSpacing: 0.5)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _modernInstruments.map((inst) {
                            final sel =
                                _selectedInstruments.contains(inst['name']);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (sel) {
                                  _selectedInstruments.remove(inst['name']);
                                } else {
                                  _selectedInstruments.add(inst['name']!);
                                }
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppTheme.primary
                                          .withValues(alpha: 0.14)
                                      : AppTheme.surfaceHigh,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sel
                                        ? AppTheme.primary
                                        : AppTheme.cardBorder,
                                    width: sel ? 1.2 : 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(inst['icon'] as IconData,
                                        color: sel
                                            ? AppTheme.primary
                                            : AppTheme.textSecondary,
                                        size: 15),
                                    const SizedBox(width: 6),
                                    Text(inst['name'] as String,
                                        style: GoogleFonts.outfit(
                                          color: sel
                                              ? AppTheme.primary
                                              : AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: sel
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        )),
                                    if (sel) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppTheme.primary, size: 13),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // Instrumental Mode Toggle
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isInstrumental = !_isInstrumental;
                        if (_isInstrumental) _lyricsController.clear();
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: _isInstrumental
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : AppTheme.surfaceHigh,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _isInstrumental
                                ? AppTheme.primary.withValues(alpha: 0.4)
                                : AppTheme.cardBorder,
                            width: _isInstrumental ? 1.2 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.piano_rounded,
                                color: _isInstrumental
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                                size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Generate Instrumental Only',
                                      style: GoogleFonts.outfit(
                                          color: _isInstrumental
                                              ? AppTheme.primary
                                              : AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700)),
                                  Text('No vocals — pure music',
                                      style: GoogleFonts.inter(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11)),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isInstrumental,
                              activeThumbColor: AppTheme.primary,
                              onChanged: (v) => setState(() {
                                _isInstrumental = v;
                                if (v) _lyricsController.clear();
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Vocal Settings (hidden when instrumental)
                if (!_isInstrumental) ...[
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  _sectionLabel('VOCAL STYLE'),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _vocalStyles.map((vs) {
                          final sel = _selectedVocalStyle == vs['label'];
                          return GestureDetector(
                            onTap: () => setState(
                                () => _selectedVocalStyle = vs['label']!),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppTheme.primary.withValues(alpha: 0.14)
                                    : AppTheme.surfaceHigh,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel
                                      ? AppTheme.primary
                                      : AppTheme.cardBorder,
                                  width: sel ? 1.2 : 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(vs['icon'] as IconData,
                                      color: sel
                                          ? AppTheme.primary
                                          : AppTheme.textSecondary,
                                      size: 15),
                                  const SizedBox(width: 7),
                                  Text(vs['label'] as String,
                                      style: GoogleFonts.outfit(
                                        color: sel
                                            ? AppTheme.primary
                                            : AppTheme.textSecondary,
                                        fontSize: 13,
                                        fontWeight: sel
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                      )),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  // Custom AI Voice toggle
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _customAiVoice = !_customAiVoice),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 13),
                          decoration: BoxDecoration(
                            color: _customAiVoice
                                ? const Color(0xFF6C3FC5)
                                    .withValues(alpha: 0.12)
                                : AppTheme.surfaceHigh,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _customAiVoice
                                  ? const Color(0xFF6C3FC5)
                                  : AppTheme.cardBorder,
                              width: _customAiVoice ? 1.2 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: _customAiVoice
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF6C3FC5),
                                            Color(0xFFE8701A)
                                          ],
                                        )
                                      : null,
                                  color: _customAiVoice
                                      ? null
                                      : AppTheme.cardBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.record_voice_over_rounded,
                                    color: _customAiVoice
                                        ? Colors.white
                                        : AppTheme.textSecondary,
                                    size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Custom AI Voice',
                                        style: GoogleFonts.outfit(
                                          color: _customAiVoice
                                              ? const Color(0xFF9B6EE8)
                                              : AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        )),
                                    Text('Generate unique AI-powered vocals',
                                        style: GoogleFonts.inter(
                                            color: AppTheme.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _customAiVoice,
                                activeThumbColor: const Color(0xFF6C3FC5),
                                onChanged: (v) =>
                                    setState(() => _customAiVoice = v),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

              ] else ...[ // ── ADVANCED MODE ─────────────────────────────────

                // Music Style (Genre)
                _sectionLabel('MUSIC STYLE'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _genres.length,
                      itemBuilder: (_, i) {
                        final g = _genres[i];
                        final sel = _selectedGenre == g['name'];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedGenre = g['name']!),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppTheme.primary.withValues(alpha: 0.14)
                                  : AppTheme.surfaceHigh,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: sel
                                    ? AppTheme.primary
                                    : AppTheme.cardBorder,
                                width: sel ? 1.3 : 0.8,
                              ),
                              boxShadow: sel
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primary
                                            .withValues(alpha: 0.22),
                                        blurRadius: 10,
                                        spreadRadius: -2,
                                      )
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(g['icon'] as IconData,
                                    color: sel
                                        ? AppTheme.primary
                                        : AppTheme.textSecondary,
                                    size: 22),
                                const SizedBox(height: 5),
                                Text(
                                  g['name'] as String,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: sel
                                        ? AppTheme.primary
                                        : AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                _sectionLabel('TEMPO'),
                SliverToBoxAdapter(
                  child: _buildChipSelector(
                    options: _tempos,
                    selected: _selectedTempo,
                    onSelect: (v) => setState(() => _selectedTempo = v),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                _sectionLabel('MOOD'),
                SliverToBoxAdapter(
                  child: _buildChipSelector(
                    options: _moods,
                    selected: _selectedMood,
                    onSelect: (v) => setState(() => _selectedMood = v),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                _sectionLabel('ENERGY'),
                SliverToBoxAdapter(
                  child: _buildChipSelector(
                    options: _energies,
                    selected: _selectedEnergy,
                    onSelect: (v) => setState(() => _selectedEnergy = v),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                _sectionLabel('DURATION'),
                SliverToBoxAdapter(
                  child: _buildChipSelector(
                    options: _durations,
                    selected: _selectedDuration,
                    onSelect: (v) => setState(() => _selectedDuration = v),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                _sectionLabel('VOCAL STYLE'),
                SliverToBoxAdapter(
                  child: _buildChipSelector(
                    options: _voices,
                    selected: _selectedVoice,
                    onSelect: (v) => setState(() {
                      _selectedVoice = v;
                      if (v == 'Instrumental') {
                        _isInstrumental = true;
                        _lyricsController.clear();
                      } else {
                        _isInstrumental = false;
                      }
                    }),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                _sectionLabel('INSTRUMENT INTENSITY'),
                SliverToBoxAdapter(
                  child: _buildChipSelector(
                    options: _intensities,
                    selected: _selectedIntensity,
                    onSelect: (v) => setState(() => _selectedIntensity = v),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                _sectionLabel('CREATIVITY'),
                SliverToBoxAdapter(
                  child: _buildChipSelector(
                    options: _creativities,
                    selected: _selectedCreativity,
                    onSelect: (v) => setState(() => _selectedCreativity = v),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                _sectionLabel('SONG VISIBILITY'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Who can listen to this song?',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildVisibilityCard(
                                label: 'Public',
                                icon: Icons.public_rounded,
                                desc: 'Anyone can listen',
                                selected: _selectedVisibility == 'Public',
                                onTap: () => setState(
                                    () => _selectedVisibility = 'Public'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildVisibilityCard(
                                label: 'Private',
                                icon: Icons.lock_rounded,
                                desc: 'Only visible to you',
                                selected: _selectedVisibility == 'Private',
                                onTap: () => setState(
                                    () => _selectedVisibility = 'Private'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ],

            // ── Generate Song Button ────────────────────────────────────────────
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
                child: _GenerateButton(
                  credits: appState.credits,
                  isAdvanced: _isAdvanced,
                  onTap: () => _showGenerateConfirmation(context, appState),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityCard({
    required String label,
    required IconData icon,
    required String desc,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.14)
              : AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.cardBorder,
            width: selected ? 1.3 : 0.8,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: -2,
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppTheme.primary : AppTheme.textMuted,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon,
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          size: 14),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenerateConfirmation(BuildContext context, AppState appState) {
    final cost = _isAdvanced ? 30 : 20;
    final remainingAfter = appState.credits - cost;
    final instrumentsText = _selectedInstruments.isEmpty
        ? 'Soroz + Benju'
        : _selectedInstruments.join(' + ');
    final vocalText = _isInstrumental
        ? 'Instrumental'
        : (_isAdvanced ? _selectedVoice : _selectedVocalStyle);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    color: AppTheme.primaryGlow, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Generate Confirmation',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Before generation review your song summary:',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _descController.text.trim().isEmpty
                        ? 'Your Song'
                        : _descController.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppTheme.cardBorder, height: 1),
                  const SizedBox(height: 12),
                  _confirmDetailRow('Genre', _selectedGenre),
                  _confirmDetailRow('Instruments', instrumentsText),
                  _confirmDetailRow('Vocal', vocalText),
                  _confirmDetailRow('Duration', _selectedDuration),
                  _confirmDetailRow('Visibility', _selectedVisibility),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3), width: 0.8),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Generation Cost',
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: AppTheme.textSecondary)),
                      Text('$cost Credits',
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Remaining',
                          style: GoogleFonts.outfit(
                              fontSize: 12, color: AppTheme.textSecondary)),
                      Text('$remainingAfter Credits',
                          style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  appState.generateSong(
                    description: _descController.text,
                    language: _selectedLang,
                    isInstrumental: _isInstrumental,
                    lyrics: _lyricsController.text,
                    instrument: instrumentsText,
                    songType: _selectedGenre,
                    voice: vocalText,
                    tempo: _selectedTempo,
                    mood: _selectedMood,
                    energy: _selectedEnergy,
                    duration: _selectedDuration,
                    intensity: _selectedIntensity,
                    creativity: _selectedCreativity,
                    isAdvanced: _isAdvanced,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text('Generate Song',
                    style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratingScreen(BuildContext context, AppState appState) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130, height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withValues(alpha: 0.06),
                    ),
                  ),
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.5),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Generating Song',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                appState.generationStatus,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: appState.generationProgress,
                  backgroundColor: AppTheme.cardBorder,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Processing...',
                      style: GoogleFonts.outfit(
                          color: AppTheme.textMuted, fontSize: 11)),
                  Text(
                    '${(appState.generationProgress * 100).toInt()}%',
                    style: GoogleFonts.outfit(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
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

// ── Mode Tab ──────────────────────────────────────────────────────────────────
class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeTab(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.cardBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? AppTheme.primary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Generate Button ────────────────────────────────────────────────────────────
class _GenerateButton extends StatefulWidget {
  final int credits;
  final bool isAdvanced;
  final VoidCallback onTap;
  const _GenerateButton({
    required this.credits,
    required this.isAdvanced,
    required this.onTap,
  });

  @override
  State<_GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<_GenerateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.25, end: 0.55)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cost = widget.isAdvanced ? 30 : 20;
    final canGenerate = widget.credits >= cost;

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) => GestureDetector(
        onTap: canGenerate ? widget.onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: canGenerate ? AppTheme.brandGradient : null,
            color: canGenerate ? null : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: canGenerate
                  ? Colors.transparent
                  : AppTheme.cardBorder,
            ),
            boxShadow: canGenerate
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: _glow.value),
                      blurRadius: 32,
                      spreadRadius: -4,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded,
                      color: canGenerate ? Colors.white : AppTheme.textMuted,
                      size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Generate Song',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: canGenerate ? Colors.white : AppTheme.textMuted,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                canGenerate
                    ? 'Uses $cost credits · ${widget.credits} remaining'
                    : 'Not enough credits ($cost needed)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: canGenerate
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
