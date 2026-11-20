import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<List<Color>> avatarGradients = [
    [Color(0xFFFF8C3A), Color(0xFFE8701A), Color(0xFFB84F10)],
    [Color(0xFF6A11CB), Color(0xFF2575FC)],
    [Color(0xFF00C6FF), Color(0xFF0072FF)],
    [Color(0xFFF857A6), Color(0xFFFF5858)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
  ];

  static const List<List<Color>> playlistGradients = [
    [Color(0xFF2E1C14), Color(0xFFE8701A)],
    [Color(0xFF14243B), Color(0xFF2575FC)],
    [Color(0xFF1A2E26), Color(0xFF2ECC71)],
    [Color(0xFF2C1434), Color(0xFF9B51E0)],
    [Color(0xFF301414), Color(0xFFEB5757)],
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Modal / Action Helpers ───────────────────────────────────────────────

  void _showPeopleSheet(BuildContext context, {int initialTab = 0}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => _PeopleListSheet(initialTab: initialTab),
    );
  }

  void _showHighlightSheet(BuildContext context, ProfileHighlight highlight) {
    final appState = Provider.of<AppState>(context, listen: false);
    final gradient =
        playlistGradients[highlight.colorIndex % playlistGradients.length];
    final song = highlight.trackId != null
        ? appState.getSongById(highlight.trackId!)
        : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF111116),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(highlight.icon, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              highlight.title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              highlight.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            if (song != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.cardBorder, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.music_note_rounded,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Track: ${song.title}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (song != null) {
                        appState.playSong(song);
                      } else {
                        appState.playRadio();
                      }
                    },
                    icon: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      song != null
                          ? 'Play Highlight Track'
                          : 'Play Live Stream',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.error,
                  ),
                  tooltip: 'Delete Highlight',
                  onPressed: () {
                    appState.deleteHighlight(highlight.id);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Highlight "${highlight.title}" deleted',
                          style: GoogleFonts.inter(fontSize: 12),
                        ),
                        backgroundColor: AppTheme.surfaceHigh,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showAddHighlightSheet(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int selectedIconIndex = 0;
    int selectedColor = 0;
    String? selectedTrackId;

    final icons = [
      {'icon': Icons.workspace_premium_rounded, 'name': 'Award 🏆'},
      {'icon': Icons.military_tech_rounded, 'name': 'Medal 🎖️'},
      {'icon': Icons.bolt_rounded, 'name': 'Album ⚡'},
      {'icon': Icons.radio_rounded, 'name': 'Live 📻'},
      {'icon': Icons.music_note_rounded, 'name': 'Suroz 🎻'},
      {'icon': Icons.mic_rounded, 'name': 'Studio 🎙️'},
      {'icon': Icons.star_rounded, 'name': 'Star 🌟'},
      {'icon': Icons.local_fire_department_rounded, 'name': 'Hot 🔥'},
      {'icon': Icons.favorite_rounded, 'name': 'Love ❤️'},
      {'icon': Icons.graphic_eq_rounded, 'name': 'Remix 🎧'},
    ];

    final availableSongs = [...appState.songs, ...appState.savedSongs];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF111116),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Highlight or Award',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppTheme.textSecondary,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF23232A), height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Quick suggestion pills
                        Text(
                          'QUICK SUGGESTIONS',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children:
                              [
                                'Awards 🏆',
                                'New Album ⚡',
                                'Live Set 📻',
                                'Suroz Jam 🎸',
                                'Best Solo 🎖️',
                                'Studio 🎙️',
                              ].map((pill) {
                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      titleCtrl.text = pill;
                                      if (pill.contains('🏆'))
                                        selectedIconIndex = 0;
                                      if (pill.contains('🎖️'))
                                        selectedIconIndex = 1;
                                      if (pill.contains('⚡'))
                                        selectedIconIndex = 2;
                                      if (pill.contains('📻'))
                                        selectedIconIndex = 3;
                                      if (pill.contains('🎸'))
                                        selectedIconIndex = 4;
                                      if (pill.contains('🎙️'))
                                        selectedIconIndex = 5;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceHigh,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppTheme.cardBorder,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      pill,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('HIGHLIGHT / AWARD TITLE'),
                        _buildTextField(
                          titleCtrl,
                          'e.g. Awards 2024, Best Balochi Solo',
                        ),
                        const SizedBox(height: 14),
                        _buildFieldLabel('CHOOSE ICON / BADGE'),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 72,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: icons.length,
                            itemBuilder: (context, i) {
                              final isSelected = selectedIconIndex == i;
                              return GestureDetector(
                                onTap: () =>
                                    setModalState(() => selectedIconIndex = i),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary.withValues(
                                            alpha: 0.2,
                                          )
                                        : AppTheme.surfaceHigh,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : AppTheme.cardBorder,
                                      width: isSelected ? 1.5 : 0.8,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        icons[i]['icon'] as IconData,
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.white70,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (icons[i]['name'] as String)
                                            .split(' ')
                                            .last,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: isSelected
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
                        const SizedBox(height: 16),
                        _buildFieldLabel('COVER ACCENT COLOR'),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(
                            playlistGradients.length,
                            (i) => GestureDetector(
                              onTap: () =>
                                  setModalState(() => selectedColor = i),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: playlistGradients[i],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: selectedColor == i
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 2.2,
                                  ),
                                ),
                                child: selectedColor == i
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('ATTACH TRACK (OPTIONAL)'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.cardBorder,
                              width: 0.8,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: selectedTrackId,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF16161C),
                              hint: Text(
                                'Select a track to play with this highlight',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(
                                    'Live Radio Stream (Default)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                ...availableSongs.map(
                                  (s) => DropdownMenuItem<String?>(
                                    value: s.id,
                                    child: Text(
                                      '${s.title} • ${s.artist}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                setModalState(() => selectedTrackId = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFieldLabel('DESCRIPTION / STORY DETAILS'),
                        _buildTextField(
                          descCtrl,
                          'Write brief details about this award or story...',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              final title = titleCtrl.text.trim();
                              if (title.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Please enter a highlight title',
                                      style: GoogleFonts.inter(fontSize: 12),
                                    ),
                                    backgroundColor: AppTheme.error,
                                  ),
                                );
                                return;
                              }
                              appState.addHighlight(
                                title: title,
                                icon:
                                    icons[selectedIconIndex]['icon']
                                        as IconData,
                                colorIndex: selectedColor,
                                trackId: selectedTrackId,
                                description: descCtrl.text.trim(),
                              );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppTheme.success,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Highlight "$title" added to your profile!',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppTheme.surfaceHigh,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Text(
                              'Add Highlight / Award',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final profile = appState.profile;

    final nameCtrl = TextEditingController(text: profile.fullName);
    final usernameCtrl = TextEditingController(text: profile.username);
    final bioCtrl = TextEditingController(text: profile.bio);
    final locationCtrl = TextEditingController(text: profile.location);
    final websiteCtrl = TextEditingController(text: profile.website);
    bool isPrivate = profile.isPrivate;
    int selectedAvatar = profile.avatarColorIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF111116),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppTheme.textSecondary,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF23232A), height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Avatar Picker
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors:
                                        avatarGradients[selectedAvatar %
                                            avatarGradients.length],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.primary,
                                    width: 2.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    usernameCtrl.text.isNotEmpty
                                        ? usernameCtrl.text[0].toUpperCase()
                                        : 'S',
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Select Avatar Style',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  avatarGradients.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      setModalState(
                                        () => selectedAvatar = index,
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                      ),
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: avatarGradients[index],
                                        ),
                                        border: Border.all(
                                          color: selectedAvatar == index
                                              ? Colors.white
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildFieldLabel('FULL NAME'),
                        _buildTextField(nameCtrl, 'Enter your full name'),
                        const SizedBox(height: 14),
                        _buildFieldLabel('USERNAME'),
                        _buildTextField(usernameCtrl, 'Enter username'),
                        const SizedBox(height: 14),
                        _buildFieldLabel('BIO'),
                        _buildTextField(
                          bioCtrl,
                          'Write a short music bio...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 14),
                        _buildFieldLabel('LOCATION (OPTIONAL)'),
                        _buildTextField(
                          locationCtrl,
                          'e.g. Quetta, Balochistan',
                        ),
                        const SizedBox(height: 14),
                        _buildFieldLabel('WEBSITE / PORTFOLIO'),
                        _buildTextField(
                          websiteCtrl,
                          'suroz.ai/creator/yourname',
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF17171C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.cardBorder,
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Private Profile',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Only approved listeners can see creations',
                                    style: GoogleFonts.inter(
                                      fontSize: 10.5,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: isPrivate,
                                activeThumbColor: AppTheme.primary,
                                onChanged: (val) {
                                  setModalState(() => isPrivate = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              final updated = profile.copyWith(
                                fullName: nameCtrl.text.trim().isNotEmpty
                                    ? nameCtrl.text.trim()
                                    : profile.fullName,
                                username: usernameCtrl.text.trim().isNotEmpty
                                    ? usernameCtrl.text.trim()
                                    : profile.username,
                                bio: bioCtrl.text.trim(),
                                location: locationCtrl.text.trim(),
                                website: websiteCtrl.text.trim(),
                                isPrivate: isPrivate,
                                avatarColorIndex: selectedAvatar,
                              );
                              appState.updateProfile(updated);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppTheme.success,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Profile successfully updated!',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppTheme.surfaceHigh,
                                ),
                              );
                            },
                            child: Text(
                              'Save Changes',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreatePlaylistSheet(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final nameCtrl = TextEditingController();
    int selectedColor = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF111116),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Create New Playlist',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('PLAYLIST TITLE'),
                  _buildTextField(
                    nameCtrl,
                    'e.g. Suroz Meditations, Balochi Folk',
                  ),
                  const SizedBox(height: 14),
                  _buildFieldLabel('COVER ART STYLE'),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      playlistGradients.length,
                      (i) => GestureDetector(
                        onTap: () => setModalState(() => selectedColor = i),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: playlistGradients[i],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: selectedColor == i
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2.2,
                            ),
                          ),
                          child: selectedColor == i
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final title = nameCtrl.text.trim();
                        if (title.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please enter a playlist title',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                              backgroundColor: AppTheme.error,
                            ),
                          );
                          return;
                        }
                        appState.createPlaylist(
                          title,
                          coverColorIndex: selectedColor,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Playlist "$title" created!',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                            backgroundColor: AppTheme.surfaceHigh,
                          ),
                        );
                      },
                      child: Text(
                        'Create Playlist',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPlaylistDetailSheet(BuildContext context, Playlist playlist) {
    final appState = Provider.of<AppState>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final tracks = appState.getPlaylistTracks(playlist);
          final gradientColors =
              playlistGradients[playlist.coverColorIndex %
                  playlistGradients.length];

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF111116),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.queue_music_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playlist.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${tracks.length} tracks • Balochi Collection',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        tooltip: 'Rename',
                        onPressed: () {
                          _showRenamePlaylistDialog(ctx, playlist, () {
                            setSheetState(() {});
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppTheme.error,
                          size: 20,
                        ),
                        tooltip: 'Delete',
                        onPressed: () {
                          appState.deletePlaylist(playlist.id);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Playlist deleted',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                              backgroundColor: AppTheme.surfaceHigh,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                if (tracks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          appState.playPlaylist(playlist);
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Play All (${tracks.length})',
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                const Divider(color: Color(0xFF23232A), height: 1),
                Expanded(
                  child: tracks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_off_outlined,
                                size: 44,
                                color: AppTheme.textMuted.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No tracks in this playlist yet',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Add tracks from Saved Music or My Music tab',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: tracks.length,
                          itemBuilder: (context, index) {
                            final song = tracks[index];
                            final isThisPlaying =
                                appState.isPlaying &&
                                appState.currentSong?.id == song.id;

                            return _SongListTile(
                              song: song,
                              isPlaying: isThisPlaying,
                              onPlay: () => appState.playSong(song),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: AppTheme.textSecondary,
                                  size: 20,
                                ),
                                tooltip: 'Remove from playlist',
                                onPressed: () {
                                  appState.removeTrackFromPlaylist(
                                    playlist.id,
                                    song.id,
                                  );
                                  setSheetState(() {});
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showRenamePlaylistDialog(
    BuildContext context,
    Playlist playlist,
    VoidCallback onRenamed,
  ) {
    final appState = Provider.of<AppState>(context, listen: false);
    final ctrl = TextEditingController(text: playlist.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16161C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Rename Playlist',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: TextField(
          controller: ctrl,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Enter new playlist name',
            filled: true,
            fillColor: AppTheme.surface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                appState.renamePlaylist(playlist.id, ctrl.text.trim());
                onRenamed();
              }
              Navigator.pop(ctx);
            },
            child: Text(
              'Rename',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistSheet(BuildContext context, Song song) {
    final appState = Provider.of<AppState>(context, listen: false);
    final playlists = appState.playlists;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF111116),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
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
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add to Playlist',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showCreatePlaylistSheet(context);
                      },
                      icon: const Icon(
                        Icons.add,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                      label: Text(
                        'New Playlist',
                        style: GoogleFonts.inter(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (playlists.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No playlists created yet. Create one first!',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  ...playlists.map((pl) {
                    final containsTrack = pl.trackIds.contains(song.id);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors:
                                playlistGradients[pl.coverColorIndex %
                                    playlistGradients.length],
                          ),
                        ),
                        child: const Icon(
                          Icons.queue_music,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        pl.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${pl.trackIds.length} tracks',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      trailing: containsTrack
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppTheme.success,
                              size: 22,
                            )
                          : const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                      onTap: () {
                        if (containsTrack) {
                          appState.removeTrackFromPlaylist(pl.id, song.id);
                          setModalState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Removed from "${pl.name}"',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                              backgroundColor: AppTheme.surfaceHigh,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } else {
                          appState.addTrackToPlaylist(pl.id, song.id);
                          setModalState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Added to "${pl.name}"!',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                              backgroundColor: AppTheme.surfaceHigh,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    );
                  }),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showShareSnackBar(BuildContext context, String username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.link_rounded, color: AppTheme.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'Profile link copied: suroz.ai/creator/$username',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceHigh,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ─── Main Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final profile = appState.profile;
    final creations = appState.songs;
    final savedSongs = appState.savedSongs;
    final playlists = appState.playlists;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textPrimary,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (profile.isPrivate) ...[
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                profile.username,
                style: GoogleFonts.spaceGrotesk(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.verified_rounded,
                size: 15,
                color: Color(0xFF3897F0),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_box_outlined,
                color: AppTheme.textPrimary,
                size: 24,
              ),
              tooltip: 'New Track / Playlist',
              onPressed: () => _showCreatePlaylistSheet(context),
            ),
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: AppTheme.textPrimary,
                size: 24,
              ),
              tooltip: 'Edit Profile & Settings',
              onPressed: () => _showEditProfileSheet(context),
            ),
          ],
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(
                    context,
                    profile: profile,
                    songsCount: creations.length,
                    followersCount: appState.followersCount,
                    followingCount: appState.followingCount,
                  ),
                  const SizedBox(height: 10),
                  // Instagram Story Highlights
                  _buildHighlightsRow(context),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primary,
                  indicatorWeight: 2.2,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.textSecondary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.grid_on_rounded, size: 20),
                      text: 'My Music (${creations.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.bookmark_rounded, size: 20),
                      text: 'Saved (${savedSongs.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.queue_music_rounded, size: 20),
                      text: 'Playlists (${playlists.length})',
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Tab 1: My Music (Uploaded / Generated) ──
            _buildMyMusicTab(context, creations, appState),

            // ── Tab 2: Saved Music (Instagram Saved tab) ──
            _buildSavedMusicTab(context, savedSongs, appState),

            // ── Tab 3: Playlists ──
            _buildPlaylistsTab(context, playlists, appState),
          ],
        ),
      ),
    );
  }

  // ─── Profile Header Widget (Instagram-exact Layout) ───────────────────────

  Widget _buildProfileHeader(
    BuildContext context, {
    required UserProfile profile,
    required int songsCount,
    required int followersCount,
    required int followingCount,
  }) {
    final avatarColors =
        avatarGradients[profile.avatarColorIndex % avatarGradients.length];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Avatar on left, 3 Stats on right: Songs | Followers | Following ──
          Row(
            children: [
              // Avatar with Story-style Gradient Ring
              GestureDetector(
                onTap: () => _showEditProfileSheet(context),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF8C3A),
                        Color(0xFFE8701A),
                        Color(0xFFFF3366),
                        Color(0xFFFF8C3A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.background,
                      border: Border.all(color: AppTheme.background, width: 2),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: avatarColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          profile.username.isNotEmpty
                              ? profile.username[0].toUpperCase()
                              : 'S',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // 3 Stat columns: Songs, Followers, Following (Instagram classic)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      count: songsCount.toString(),
                      label: 'Songs',
                      onTap: () => _tabController.animateTo(0),
                    ),
                    _buildStatColumn(
                      count: _formatNumber(followersCount),
                      label: 'Followers',
                      onTap: () => _showPeopleSheet(context, initialTab: 0),
                    ),
                    _buildStatColumn(
                      count: _formatNumber(followingCount),
                      label: 'Following',
                      onTap: () => _showPeopleSheet(context, initialTab: 1),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Row 2: Full Name, Category, Bio, Location, Website, Creation Date ──
          Row(
            children: [
              Text(
                profile.fullName,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'BALOCHI AI',
                  style: GoogleFonts.outfit(
                    color: AppTheme.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            profile.category,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profile.bio,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textPrimary.withValues(alpha: 0.9),
                height: 1.35,
              ),
            ),
          ],
          if (profile.location.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 3),
                Text(
                  profile.location,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (profile.website.isNotEmpty) ...[
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => _showShareSnackBar(context, profile.username),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    size: 13,
                    color: Color(0xFF4FA5FF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    profile.website,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4FA5FF),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'Joined ${_formatDate(profile.joinedAt)}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Row 3: Action Buttons (Edit Profile, Share Profile, Add Award/Highlight, Add Playlist) ──
          Row(
            children: [
              Expanded(
                child: _buildInstagramButton(
                  label: 'Edit profile',
                  icon: Icons.edit_outlined,
                  onTap: () => _showEditProfileSheet(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildInstagramButton(
                  label: 'Share profile',
                  icon: Icons.share_outlined,
                  onTap: () => _showShareSnackBar(context, profile.username),
                ),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.workspace_premium_rounded,
                tooltip: 'Add Award or Highlight',
                onTap: () => _showAddHighlightSheet(context),
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                icon: Icons.playlist_add_rounded,
                tooltip: 'Add Playlist',
                onTap: () => _showCreatePlaylistSheet(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Instagram Story Highlights Row ───────────────────────────────────────

  Widget _buildHighlightsRow(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final highlights = appState.highlights;

    return SizedBox(
      height: 94,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: highlights.length + 1,
        itemBuilder: (context, index) {
          if (index == highlights.length) {
            // "+ New" Highlight button
            return GestureDetector(
              onTap: () => _showAddHighlightSheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.cardBorder,
                          width: 1.2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'New',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final h = highlights[index];
          final gradient =
              playlistGradients[h.colorIndex % playlistGradients.length];

          return GestureDetector(
            onTap: () => _showHighlightSheet(context, h),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.cardBorder,
                        width: 1.2,
                      ),
                      color: AppTheme.surfaceHigh,
                    ),
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(h.icon, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    h.title,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatColumn({
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF23232A),
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF33333E), width: 0.8),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF23232A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF33333E), width: 0.8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        padding: EdgeInsets.zero,
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  // ─── Tab 1: My Music View (Instagram Grid) ────────────────────────────────

  Widget _buildMyMusicTab(
    BuildContext context,
    List<Song> songs,
    AppState appState,
  ) {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music_outlined,
              size: 46,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              'No music created yet',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create new Balochi tunes in the Studio tab',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => appState.setTabIndex(2),
              child: Text(
                'Create Music',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(3),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        childAspectRatio: 1.0,
      ),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final palette = playlistGradients[index % playlistGradients.length];
        final isThisPlaying =
            appState.isPlaying && appState.currentSong?.id == song.id;
        final isSaved = appState.isSongSaved(song);

        return GestureDetector(
          onTap: () => appState.playSong(song),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: palette,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: isThisPlaying
                  ? Border.all(color: AppTheme.primary, width: 2)
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: Icon(
                    isThisPlaying
                        ? Icons.pause_rounded
                        : Icons.music_note_rounded,
                    color: Colors.white.withValues(
                      alpha: isThisPlaying ? 0.8 : 0.28,
                    ),
                    size: 32,
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  right: 6,
                  child: Text(
                    song.title,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  right: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isThisPlaying
                                ? Icons.volume_up_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          Text(
                            _formatDuration(song.duration),
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          appState.toggleSaveSong(song);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isSaved
                                    ? 'Removed from saved music'
                                    : 'Saved to library',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                              backgroundColor: AppTheme.surfaceHigh,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isSaved ? AppTheme.primary : Colors.white70,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Tab 2: Saved Music System (Instagram Saved Tab Style) ────────────────

  Widget _buildSavedMusicTab(
    BuildContext context,
    List<Song> savedSongs,
    AppState appState,
  ) {
    if (savedSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceHigh,
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 32,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No Saved Music',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Save tracks you discover across SUROZ AI by clicking the bookmark icon.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => appState.setTabIndex(1), // Discover tab
              child: Text(
                'Discover Music',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      itemCount: savedSongs.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final song = savedSongs[index];
        final gradient = playlistGradients[index % playlistGradients.length];
        final isThisPlaying =
            appState.isPlaying && appState.currentSong?.id == song.id;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isThisPlaying
                  ? AppTheme.primary.withValues(alpha: 0.6)
                  : AppTheme.cardBorder,
              width: isThisPlaying ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              // Music cover artwork with play/pause button overlay
              GestureDetector(
                onTap: () => appState.playSong(song),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: isThisPlaying
                        ? [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isThisPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Title, Artist, Instrument Tag, Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isThisPlaying
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      song.artist,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            song.tags.isNotEmpty ? song.tags.first : 'Suroz',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(song.duration),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Add to Playlist button
              IconButton(
                icon: const Icon(
                  Icons.playlist_add_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                tooltip: 'Add to Playlist',
                onPressed: () => _showAddToPlaylistSheet(context, song),
              ),

              // Save / Unsave bookmark icon
              IconButton(
                icon: const Icon(
                  Icons.bookmark_rounded,
                  color: AppTheme.primary,
                  size: 22,
                ),
                tooltip: 'Unsave Music',
                onPressed: () {
                  appState.toggleSaveSong(song);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.bookmark_remove_outlined,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Track unsaved from personal library',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                        ],
                      ),
                      backgroundColor: AppTheme.surfaceHigh,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Tab 3: Playlists View ────────────────────────────────────────────────

  Widget _buildPlaylistsTab(
    BuildContext context,
    List<Playlist> playlists,
    AppState appState,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        // Create Playlist Banner
        GestureDetector(
          onTap: () => _showCreatePlaylistSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.35),
                width: 0.9,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Playlist',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Organize your favorite Balochi tunes',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Playlists List or Empty State
        if (playlists.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    size: 42,
                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No playlists yet',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "Create New Playlist" above to start one.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...playlists.map((playlist) {
            final gradient =
                playlistGradients[playlist.coverColorIndex %
                    playlistGradients.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                tileColor: AppTheme.cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: AppTheme.cardBorder,
                    width: 0.8,
                  ),
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.queue_music_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                title: Text(
                  playlist.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${playlist.trackIds.length} tracks',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.play_circle_fill_rounded,
                        color: AppTheme.primary,
                        size: 28,
                      ),
                      onPressed: () {
                        final tracks = appState.getPlaylistTracks(playlist);
                        if (tracks.isNotEmpty) {
                          appState.playSong(tracks.first);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Playlist is empty',
                                style: GoogleFonts.inter(fontSize: 12),
                              ),
                              backgroundColor: AppTheme.surfaceHigh,
                            ),
                          );
                        }
                      },
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                  ],
                ),
                onTap: () => _showPlaylistDetailSheet(context, playlist),
              ),
            );
          }),
      ],
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  static String _formatNumber(int n) {
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    } else if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toString();
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

// ─── People List Sheet (Instagram-identical Followers & Following) ───────────

class _PeopleListSheet extends StatefulWidget {
  final int initialTab;
  const _PeopleListSheet({this.initialTab = 0});

  @override
  State<_PeopleListSheet> createState() => _PeopleListSheetState();
}

class _PeopleListSheetState extends State<_PeopleListSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _tabCtrl.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final followersList = appState.followers;
    final followingList = appState.followingList;

    final currentList = _tabCtrl.index == 0 ? followersList : followingList;
    final filtered = _query.isEmpty
        ? currentList
        : currentList.where((u) {
            final q = _query.toLowerCase();
            return u.name.toLowerCase().contains(q) ||
                u.username.toLowerCase().contains(q);
          }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111116),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
              child: Row(
                children: [
                  Text(
                    appState.profile.username,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.verified_rounded,
                    size: 15,
                    color: Color(0xFF3897F0),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabCtrl,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 2,
              labelColor: AppTheme.textPrimary,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: '${appState.followersCount} Followers'),
                Tab(text: '${appState.followingCount} Following'),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.cardBorder, width: 0.8),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search Balochi creators & listeners...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppTheme.textMuted,
                      size: 18,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: Color(0xFF23232A), height: 1),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 40,
                            color: AppTheme.textMuted.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _query.isEmpty
                                ? 'No accounts in this list'
                                : 'No matching creators found',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final user = filtered[index];
                        final avatarGradient =
                            _ProfileScreenState.avatarGradients[user
                                    .avatarColorIndex %
                                _ProfileScreenState.avatarGradients.length];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: avatarGradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : 'U',
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user.name,
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified_rounded,
                                          size: 13,
                                          color: Color(0xFF3897F0),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '@${user.username}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      user.subtitle,
                                      style: GoogleFonts.inter(
                                        fontSize: 10.5,
                                        color: AppTheme.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  appState.toggleFollowUser(user);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        user.isFollowing
                                            ? 'You are now following ${user.name}'
                                            : 'Unfollowed ${user.name}',
                                        style: GoogleFonts.inter(fontSize: 12),
                                      ),
                                      backgroundColor: AppTheme.surfaceHigh,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: user.isFollowing
                                        ? const Color(0xFF23232A)
                                        : AppTheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: user.isFollowing
                                          ? const Color(0xFF33333E)
                                          : AppTheme.primary,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    user.isFollowing ? 'Following' : 'Follow',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
}

// ─── Song List Tile for Playlists ───────────────────────────────────────────

class _SongListTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onPlay;
  final Widget trailing;

  const _SongListTile({
    required this.song,
    this.isPlaying = false,
    required this.onPlay,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
          border: isPlaying
              ? Border.all(color: AppTheme.primary, width: 1.5)
              : null,
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.music_note_rounded,
          color: isPlaying ? AppTheme.primary : AppTheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        song.title,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isPlaying ? AppTheme.primary : AppTheme.textPrimary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} • ${song.duration.inMinutes}:${(song.duration.inSeconds % 60).toString().padLeft(2, '0')}',
        style: GoogleFonts.inter(fontSize: 10.5, color: AppTheme.textSecondary),
      ),
      onTap: onPlay,
      trailing: trailing,
    );
  }
}

// ─── SliverTabBarDelegate ───────────────────────────────────────────────────

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(
          bottom: BorderSide(color: AppTheme.cardBorder, width: 0.5),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
