import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_track/presentation/widgets/streak_badge.dart';

void main() {
  Widget app(StreakBadge badge) => MaterialApp(home: Scaffold(body: badge));

  testWidgets('shows empty freeze slots and counter', (tester) async {
    await tester.pumpWidget(app(const StreakBadge(streakCount: 0)));

    expect(find.text('0/2'), findsOneWidget);
    expect(find.byIcon(Icons.ac_unit_rounded), findsNWidgets(2));
  });

  testWidgets('shows full freezes when the maximum is held', (tester) async {
    await tester.pumpWidget(
      app(const StreakBadge(streakCount: 4, freezesAvailable: 2)),
    );

    expect(find.text('2/2'), findsOneWidget);
    expect(find.text('Freezes full ❄️'), findsOneWidget);
  });

  testWidgets('uses singular day wording', (tester) async {
    await tester.pumpWidget(
      app(const StreakBadge(streakCount: 4, daysUntilNextFreeze: 1)),
    );

    expect(find.text('Next freeze in 1 perfect day'), findsOneWidget);
  });

  testWidgets('uses singular and plural streak labels', (tester) async {
    await tester.pumpWidget(app(const StreakBadge(streakCount: 1)));
    expect(find.text('DAY STREAK'), findsOneWidget);

    await tester.pumpWidget(app(const StreakBadge(streakCount: 2)));
    expect(find.text('DAYS STREAK'), findsOneWidget);
  });
}
