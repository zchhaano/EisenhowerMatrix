import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eisenhower_matrix/features/quadrant/domain/entities/quadrant.dart';
import 'package:eisenhower_matrix/features/quadrant/presentation/widgets/quick_add_bottom_sheet.dart';

/// Pump the QuickAddBottomSheet inside a MaterialApp and trigger the
/// modal bottom sheet so the widget is actually rendered.
Future<void> pumpBottomSheet(
  WidgetTester tester,
  QuadrantType quadrant, {
  Function(String, String?, DateTime?, int)? onSave,
  VoidCallback? onVoiceInput,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: ElevatedButton(
            key: const Key('open_btn'),
            onPressed: () => QuickAddBottomSheet.show(
              context: ctx,
              quadrant: quadrant,
              onSave: onSave ?? (_, __, ___, ____) {},
              onVoiceInput: onVoiceInput,
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );

  // Open the bottom sheet
  await tester.tap(find.byKey(const Key('open_btn')));
  await tester.pumpAndSettle();
}

void main() {
  group('QuickAddBottomSheet', () {
    group('Header display', () {
      testWidgets('shows pre-selected quadrant label in header for Q1',
          (tester) async {
        await pumpBottomSheet(tester, QuadrantType.first);

        expect(find.textContaining('Do First'), findsOneWidget,
            reason: 'Header should show quadrant label "Do First"');
      });

      testWidgets('shows pre-selected quadrant label in header for Q2',
          (tester) async {
        await pumpBottomSheet(tester, QuadrantType.second);

        expect(find.textContaining('Schedule'), findsOneWidget,
            reason: 'Header should show quadrant label "Schedule"');
      });

      testWidgets('shows Chinese label alongside English label', (tester) async {
        await pumpBottomSheet(tester, QuadrantType.second);

        expect(find.textContaining('计划做'), findsOneWidget,
            reason: 'Chinese label should appear in header');
      });
    });

    group('Text input', () {
      testWidgets('renders a TextField for task title', (tester) async {
        await pumpBottomSheet(tester, QuadrantType.second);

        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('shows hint text in the text field', (tester) async {
        await pumpBottomSheet(tester, QuadrantType.second);

        expect(find.textContaining('task title'), findsOneWidget);
      });

      testWidgets('user can type in the text field', (tester) async {
        await pumpBottomSheet(tester, QuadrantType.second);

        await tester.enterText(find.byType(TextField), 'My new task');
        expect(find.text('My new task'), findsOneWidget);
      });
    });

    group('Save action', () {
      testWidgets('calls onSave with title when Add Task button tapped',
          (tester) async {
        String? capturedTitle;

        await pumpBottomSheet(
          tester,
          QuadrantType.second,
          onSave: (title, desc, date, priority) {
            capturedTitle = title;
          },
        );

        await tester.enterText(find.byType(TextField), 'Buy groceries');
        await tester.tap(find.text('Add Task'));
        await tester.pumpAndSettle();

        expect(capturedTitle, 'Buy groceries',
            reason: 'onSave should be called with the entered task title');
      });

      testWidgets('dismisses sheet after save', (tester) async {
        await pumpBottomSheet(tester, QuadrantType.second);

        await tester.enterText(find.byType(TextField), 'Plan meeting');
        await tester.tap(find.text('Add Task'));
        await tester.pumpAndSettle();

        // Bottom sheet should be gone
        expect(find.byType(QuickAddBottomSheet), findsNothing,
            reason: 'Bottom sheet should dismiss after save');
      });

      testWidgets('does not call onSave when title is empty', (tester) async {
        bool saveCalled = false;

        await pumpBottomSheet(
          tester,
          QuadrantType.second,
          onSave: (_, __, ___, ____) => saveCalled = true,
        );

        // Don't type anything, tap save
        await tester.tap(find.text('Add Task'));
        await tester.pumpAndSettle();

        expect(saveCalled, isFalse,
            reason: 'onSave should not be called when title is empty');
      });
    });

    group('Keyboard submit (Enter key)', () {
      testWidgets('pressing Enter/done on keyboard triggers save',
          (tester) async {
        String? capturedTitle;

        await pumpBottomSheet(
          tester,
          QuadrantType.first,
          onSave: (title, _, __, ___) => capturedTitle = title,
        );

        await tester.enterText(find.byType(TextField), 'Complete report');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(capturedTitle, 'Complete report',
            reason: 'TextInputAction.done should trigger save');
      });
    });

    group('Cancel action', () {
      testWidgets('cancel button dismisses the sheet without saving',
          (tester) async {
        bool saveCalled = false;

        await pumpBottomSheet(
          tester,
          QuadrantType.third,
          onSave: (_, __, ___, ____) => saveCalled = true,
        );

        await tester.enterText(find.byType(TextField), 'Some task');
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(saveCalled, isFalse,
            reason: 'Cancel should not call onSave');
        expect(find.byType(QuickAddBottomSheet), findsNothing,
            reason: 'Cancel should dismiss the bottom sheet');
      });
    });

    group('Voice input button', () {
      testWidgets('voice button not shown when onVoiceInput is null',
          (tester) async {
        await pumpBottomSheet(tester, QuadrantType.second);

        expect(find.byIcon(Icons.mic_none), findsNothing,
            reason: 'Mic button should be hidden when onVoiceInput is null');
      });

      testWidgets('voice button shown when onVoiceInput is provided',
          (tester) async {
        await pumpBottomSheet(
          tester,
          QuadrantType.second,
          onVoiceInput: () {},
        );

        expect(
          find.byWidgetPredicate((w) =>
              w is Icon &&
              (w.icon == Icons.mic_none || w.icon == Icons.mic)),
          findsOneWidget,
          reason: 'Mic button should appear when onVoiceInput is provided',
        );
      });

      testWidgets('tapping voice button triggers onVoiceInput callback',
          (tester) async {
        bool voiceTapped = false;

        await pumpBottomSheet(
          tester,
          QuadrantType.second,
          onVoiceInput: () => voiceTapped = true,
        );

        await tester.tap(find.byIcon(Icons.mic_none));
        await tester.pump();

        expect(voiceTapped, isTrue,
            reason: 'onVoiceInput should be called when mic button is tapped');
      });
    });
  });
}
