import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eisenhower_matrix/features/quadrant/domain/entities/quadrant.dart';
import 'package:eisenhower_matrix/features/quadrant/presentation/widgets/quadrant_card.dart';

/// Helper: wraps widget in a minimal MaterialApp so Theme/MediaQuery work
Widget wrapWithMaterial(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 300,
        height: 300,
        child: child,
      ),
    ),
  );
}

void main() {
  group('QuadrantCard – long-press gesture', () {
    testWidgets('calls onLongPress callback when long-pressed', (tester) async {
      bool longPressTriggered = false;

      await tester.pumpWidget(
        wrapWithMaterial(
          QuadrantCard(
            quadrantType: QuadrantType.second,
            onLongPress: () => longPressTriggered = true,
          ),
        ),
      );

      // Long-press on the quadrant card
      await tester.longPress(find.byType(QuadrantCard));
      await tester.pumpAndSettle();

      expect(longPressTriggered, isTrue,
          reason: 'onLongPress should be invoked after a long-press gesture');
    });

    testWidgets('does not call onLongPress when not long-pressed (tap only)',
        (tester) async {
      bool longPressTriggered = false;

      await tester.pumpWidget(
        wrapWithMaterial(
          QuadrantCard(
            quadrantType: QuadrantType.first,
            onLongPress: () => longPressTriggered = true,
          ),
        ),
      );

      // Regular tap — should not trigger long-press
      await tester.tap(find.byType(QuadrantCard));
      await tester.pumpAndSettle();

      expect(longPressTriggered, isFalse,
          reason: 'A regular tap should not trigger onLongPress');
    });

    testWidgets('shows visual feedback animation during long-press',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          QuadrantCard(
            quadrantType: QuadrantType.second,
            onLongPress: () {},
          ),
        ),
      );

      // Start a long-press gesture (hold down)
      final gesture = await tester.startGesture(tester.getCenter(find.byType(QuadrantCard)));
      // Pump to see intermediate animation frames
      await tester.pump(const Duration(milliseconds: 200));

      // The card should have an AnimatedBuilder (scale feedback) in its tree
      expect(find.byType(AnimatedBuilder), findsWidgets,
          reason: 'Visual scale feedback animation should be active during long-press');

      // Release the gesture cleanly
      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('renders without onLongPress (null) without throwing',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const QuadrantCard(
            quadrantType: QuadrantType.third,
            // onLongPress intentionally omitted
          ),
        ),
      );

      expect(find.byType(QuadrantCard), findsOneWidget,
          reason: 'QuadrantCard should render without an onLongPress callback');
    });

    testWidgets('QuadrantCard renders correct quadrant label', (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const QuadrantCard(
            quadrantType: QuadrantType.second,
          ),
        ),
      );

      // Q2 is "Schedule"
      expect(find.textContaining('Schedule'), findsOneWidget);
    });

    testWidgets(
        'drag gesture on QuadrantCard does not accidentally trigger onLongPress',
        (tester) async {
      bool longPressTriggered = false;

      await tester.pumpWidget(
        wrapWithMaterial(
          QuadrantCard(
            quadrantType: QuadrantType.first,
            onLongPress: () => longPressTriggered = true,
          ),
        ),
      );

      // Simulate a drag (not a long-press)
      await tester.drag(find.byType(QuadrantCard), const Offset(0, 50));
      await tester.pumpAndSettle();

      expect(longPressTriggered, isFalse,
          reason: 'Drag gesture should not trigger long-press callback');
    });
  });
}
