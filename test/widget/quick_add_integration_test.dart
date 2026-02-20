import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eisenhower_matrix/features/quadrant/domain/entities/quadrant.dart';
import 'package:eisenhower_matrix/features/quadrant/presentation/widgets/quadrant_card.dart';
import 'package:eisenhower_matrix/features/quadrant/presentation/widgets/quick_add_bottom_sheet.dart';

/// Integration test covering the complete quick-add flow:
///   Long-press QuadrantCard → QuickAddBottomSheet opens (for correct quadrant)
///   → User types task title → Save → onSave callback fires with correct data
///
/// This test wires a QuadrantCard to open the bottom sheet on long-press,
/// mirroring exactly how HomeScreen connects the two widgets.
void main() {
  group('Quick-Add Flow – Integration', () {
    /// Builds the integrated widget tree: QuadrantCard → QuickAddBottomSheet.
    Widget buildIntegratedTree({
      required QuadrantType quadrant,
      required Function(String, String?, DateTime?, int) onSave,
      VoidCallback? onVoiceInput,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => SizedBox(
              width: 350,
              height: 400,
              child: QuadrantCard(
                quadrantType: quadrant,
                onLongPress: () => QuickAddBottomSheet.show(
                  context: ctx,
                  quadrant: quadrant,
                  onSave: onSave,
                  onVoiceInput: onVoiceInput,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets(
        'long-pressing QuadrantCard opens QuickAddBottomSheet for correct quadrant',
        (tester) async {
      await tester.pumpWidget(
        buildIntegratedTree(
          quadrant: QuadrantType.second,
          onSave: (_, __, ___, ____) {},
        ),
      );

      // Long-press the card
      await tester.longPress(find.byType(QuadrantCard));
      await tester.pumpAndSettle();

      // Bottom sheet should be open
      expect(find.byType(QuickAddBottomSheet), findsOneWidget);
    });

    testWidgets(
        'QuickAddBottomSheet is pre-populated with the correct quadrant (Q2)',
        (tester) async {
      await tester.pumpWidget(
        buildIntegratedTree(
          quadrant: QuadrantType.second,
          onSave: (_, __, ___, ____) {},
        ),
      );

      await tester.longPress(find.byType(QuadrantCard));
      await tester.pumpAndSettle();

      // Header should say "Add to Schedule" (Q2 label)
      expect(find.textContaining('Schedule'), findsOneWidget,
          reason: 'Bottom sheet should be pre-selected to the long-pressed quadrant');
    });

    testWidgets('full flow: long-press → type title → save → onSave fires',
        (tester) async {
      String? savedTitle;
      String? savedDescription;
      DateTime? savedDueDate;
      int? savedPriority;

      await tester.pumpWidget(
        buildIntegratedTree(
          quadrant: QuadrantType.first,
          onSave: (title, desc, dueDate, priority) {
            savedTitle = title;
            savedDescription = desc;
            savedDueDate = dueDate;
            savedPriority = priority;
          },
        ),
      );

      // 1. Long-press to open quick-add
      await tester.longPress(find.byType(QuadrantCard));
      await tester.pumpAndSettle();

      expect(find.byType(QuickAddBottomSheet), findsOneWidget);

      // 2. Type a task title
      await tester.enterText(find.byType(TextField), 'Finish project proposal');
      await tester.pumpAndSettle();

      // 3. Tap Save
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // 4. Verify onSave was called with the correct title
      expect(savedTitle, 'Finish project proposal',
          reason: 'onSave should receive the task title entered by the user');

      // 5. Sheet should be dismissed
      expect(find.byType(QuickAddBottomSheet), findsNothing);
    });

    testWidgets('full flow: long-press → type NLP input → save parses date/priority',
        (tester) async {
      int capturedPriority = 0;

      await tester.pumpWidget(
        buildIntegratedTree(
          quadrant: QuadrantType.first,
          onSave: (_, __, ___, priority) {
            capturedPriority = priority;
          },
        ),
      );

      await tester.longPress(find.byType(QuadrantCard));
      await tester.pumpAndSettle();

      // Type natural language input with priority keyword
      await tester.enterText(find.byType(TextField), '高优：完成项目报告');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // NLP parser should detect high priority keyword
      expect(capturedPriority, greaterThan(0),
          reason: 'NLP parser should extract priority from "高优" keyword');
    });

    testWidgets('cancel dismisses sheet without firing onSave', (tester) async {
      bool saveCalled = false;

      await tester.pumpWidget(
        buildIntegratedTree(
          quadrant: QuadrantType.second,
          onSave: (_, __, ___, ____) => saveCalled = true,
        ),
      );

      await tester.longPress(find.byType(QuadrantCard));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Some task');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(saveCalled, isFalse);
      expect(find.byType(QuickAddBottomSheet), findsNothing);
    });

    testWidgets('keyboard submit (Enter) triggers save and dismisses sheet',
        (tester) async {
      String? capturedTitle;

      await tester.pumpWidget(
        buildIntegratedTree(
          quadrant: QuadrantType.third,
          onSave: (title, _, __, ___) => capturedTitle = title,
        ),
      );

      await tester.longPress(find.byType(QuadrantCard));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Quick keyboard task');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(capturedTitle, 'Quick keyboard task');
      expect(find.byType(QuickAddBottomSheet), findsNothing);
    });

    testWidgets('each quadrant opens sheet with its own label',
        (tester) async {
      final expectations = {
        QuadrantType.first: 'Do First',
        QuadrantType.second: 'Schedule',
        QuadrantType.third: 'Delegate',
        QuadrantType.fourth: 'Delete',
      };

      for (final entry in expectations.entries) {
        await tester.pumpWidget(
          buildIntegratedTree(
            quadrant: entry.key,
            onSave: (_, __, ___, ____) {},
          ),
        );

        await tester.longPress(find.byType(QuadrantCard));
        await tester.pumpAndSettle();

        expect(
          find.textContaining(entry.value),
          findsOneWidget,
          reason: 'Sheet header should show "${entry.value}" for ${entry.key}',
        );

        // Dismiss before next iteration
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      }
    });
  });
}
