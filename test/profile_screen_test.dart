import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:soroz_app/screens/profile_screen.dart';
import 'package:soroz_app/state/app_state.dart';

void main() {
  testWidgets('ProfileScreen renders all features and interactions properly',
      (WidgetTester tester) async {
    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Profile header elements
    expect(find.text('Songs'), findsOneWidget);
    expect(find.text('Followers'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
    expect(find.textContaining('Joined'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Share profile'), findsOneWidget);

    // 2. Verify Tab labels with counts
    expect(find.textContaining('My Music'), findsOneWidget);
    expect(find.textContaining('Saved'), findsWidgets);
    expect(find.textContaining('Playlists'), findsWidgets);

    // 3. Test tap on Followers opens people sheet
    await tester.tap(find.text('Followers'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Followers'), findsWidgets);
    expect(find.textContaining('Following'), findsWidgets);

    // Test follow / unfollow toggle
    final followBtn = find.text('Follow').first;
    await tester.tap(followBtn);
    await tester.pumpAndSettle();

    // Close the sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // 4. Test Highlights row: tap "+ New" to add Highlight / Award
    expect(find.text('New'), findsOneWidget);
    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();
    expect(find.text('New Highlight or Award'), findsOneWidget);

    // Enter title in textfield
    final titleField = find.byType(TextField).first;
    await tester.enterText(titleField, 'My Award 🏆');
    await tester.pumpAndSettle();

    // Drag list view down to reveal Add Highlight / Award button
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();

    final addBtn = find.text('Add Highlight / Award');
    await tester.tap(addBtn);
    await tester.pumpAndSettle();
    expect(find.textContaining('added to your profile!'), findsOneWidget);

    // 5. Test tap on existing highlight opens viewer sheet
    await tester.tap(find.text('Live 📻').first);
    await tester.pumpAndSettle();
    expect(find.text('Live 📻'), findsWidgets);
    expect(find.text('Play Live Stream'), findsOneWidget);

    // Close highlight viewer sheet
    await tester.tap(find.text('Play Live Stream'));
    await tester.pumpAndSettle();

    // 6. Test Edit Profile sheet
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsOneWidget);

    // Close Edit Profile sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // 7. Test switching to Saved Music tab
    await tester.tap(find.textContaining('Saved').first);
    await tester.pumpAndSettle();

    // 8. Test switching to Playlists tab
    await tester.tap(find.textContaining('Playlists').first);
    await tester.pumpAndSettle();
    expect(find.text('Create New Playlist'), findsOneWidget);

    // 9. Test open Create Playlist sheet
    await tester.tap(find.text('Create New Playlist'));
    await tester.pumpAndSettle();
    expect(find.text('PLAYLIST TITLE'), findsOneWidget);
  });
}
