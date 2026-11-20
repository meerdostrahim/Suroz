import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/waveform_visualizer.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // List of mockup community drifts
    final List<Map<String, dynamic>> drifts = [
      {
        'id': 'drift_coastal',
        'title': 'Coastal Evening Drift',
        'time': 'Captured 4 min ago',
        'tags': ['Calm', 'Dambora'],
        'instrument': 'Dambora',
        'voice': 'Instrumental',
        'mood': 'Calm',
        'region': 'Coastal',
        'color': const Color(0xFF1E3D59),
      },
      {
        'id': 'drift_desert',
        'title': 'Desert Night Fragment',
        'time': 'Captured 11 min ago',
        'tags': ['Low', 'Suroz'],
        'instrument': 'Suroz',
        'voice': 'Instrumental',
        'mood': 'Low',
        'region': 'Makkuran',
        'color': const Color(0xFF17B890),
      },
      {
        'id': 'drift_wedding',
        'title': 'Wedding Drum Moment',
        'time': 'Captured 18 min ago',
        'tags': ['Bright', 'Duholl'],
        'instrument': 'Duholl',
        'voice': 'Instrumental',
        'mood': 'Bright',
        'region': 'Highland',
        'color': const Color(0xFFFF6F59),
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & Search
              Text(
                'Discover',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Find sounds, instruments, and moments from the Soroz community. Tap to listen or remix.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search instruments, sounds, creators...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
                  filled: true,
                  fillColor: AppTheme.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
              ),
              const SizedBox(height: 28),

              // Live section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LIVE FROM THE DRIFT',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'What the community is capturing',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textSecondary),
                ],
              ),
              const SizedBox(height: 16),

              // Drifts list - horizontal scrolling cards
              SizedBox(
                height: 310,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: drifts.length,
                  itemBuilder: (context, index) {
                    final drift = drifts[index];
                    final isPlayingThisDrift = appState.isRadioActive &&
                        appState.isPlaying &&
                        appState.radioTuning['instrument'] == drift['instrument'];

                    return Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: AppTheme.card(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover image card area
                          Stack(
                            children: [
                              Container(
                                height: 130,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      drift['color'].withValues(alpha: 0.8),
                                      drift['color'].withValues(alpha: 0.3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.insights_outlined,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    size: 40,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '30s',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              // Waveform if playing
                              if (isPlayingThisDrift)
                                Positioned(
                                  bottom: 8,
                                  left: 12,
                                  right: 12,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      padding: const EdgeInsets.all(4),
                                      child: const WaveformVisualizer(
                                        isPlaying: true,
                                        height: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          
                          // Details
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  drift['title'],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  drift['time'],
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                                ),
                                const SizedBox(height: 12),
                                // Tags row
                                Row(
                                  children: (drift['tags'] as List<String>).map((tag) {
                                    return Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surface,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                // Actions
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          if (isPlayingThisDrift) {
                                            appState.togglePlay();
                                          } else {
                                            appState.tuneRadio(
                                              drift['mood'],
                                              drift['voice'],
                                              drift['instrument'],
                                              drift['region'],
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: BorderSide(
                                            color: isPlayingThisDrift ? AppTheme.primary : AppTheme.cardBorder,
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        icon: Icon(
                                          isPlayingThisDrift ? Icons.pause : Icons.play_arrow,
                                          size: 14,
                                        ),
                                        label: Text(
                                          isPlayingThisDrift ? 'Pause' : 'Play',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Turn to Song Remix Icon
                                    IconButton(
                                      onPressed: () {
                                        // Trigger remix (goes to Create screen and sets values)
                                        appState.setTabIndex(1);
                                        // Alert user they can edit it
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: AppTheme.cardBg,
                                            content: Text(
                                              'Loaded ${drift['title']} settings into Create Studio!',
                                              style: const TextStyle(color: AppTheme.primaryGlow, fontSize: 12),
                                            ),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.all(12),
                                      ),
                                      icon: const Icon(Icons.loop, color: AppTheme.primary, size: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Trending Tracks List
              Text(
                'Trending Creations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Trending items
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  final titles = ['Coastal breeze rhythm', 'Acoustic Suroz Jam', 'Makkuran wedding loop'];
                  final creators = ['user_489', 'balochi_vibes', 'suroz_master'];
                  final likes = ['1.2k', '892', '512'];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: AppTheme.card(),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.music_note, color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                titles[index],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'by ${creators[index]}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: AppTheme.textSecondary, size: 14),
                            const SizedBox(width: 4),
                            Text(likes[index], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 80), // Padding to prevent nav overlap
            ],
          ),
        ),
      ),
    );
  }
}
