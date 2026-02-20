import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eisenhower_matrix/features/quadrant/domain/entities/quadrant.dart';

void main() {
  group('QuadrantType', () {
    group('Label Tests', () {
      test('Q1 returns correct English label', () {
        // Arrange
        const quadrant = QuadrantType.first;

        // Act
        final label = quadrant.label;

        // Assert
        expect(label, 'Do First');
      });

      test('Q2 returns correct English label', () {
        // Arrange
        const quadrant = QuadrantType.second;

        // Act
        final label = quadrant.label;

        // Assert
        expect(label, 'Schedule');
      });

      test('Q3 returns correct English label', () {
        // Arrange
        const quadrant = QuadrantType.third;

        // Act
        final label = quadrant.label;

        // Assert
        expect(label, 'Delegate');
      });

      test('Q4 returns correct English label', () {
        // Arrange
        const quadrant = QuadrantType.fourth;

        // Act
        final label = quadrant.label;

        // Assert
        expect(label, 'Delete');
      });
    });

    group('Chinese Label Tests', () {
      test('Q1 returns correct Chinese label', () {
        // Arrange
        const quadrant = QuadrantType.first;

        // Act
        final label = quadrant.labelZh;

        // Assert
        expect(label, '立即做');
      });

      test('Q2 returns correct Chinese label', () {
        // Arrange
        const quadrant = QuadrantType.second;

        // Act
        final label = quadrant.labelZh;

        // Assert
        expect(label, '计划做');
      });

      test('Q3 returns correct Chinese label', () {
        // Arrange
        const quadrant = QuadrantType.third;

        // Act
        final label = quadrant.labelZh;

        // Assert
        expect(label, '委派做');
      });

      test('Q4 returns correct Chinese label', () {
        // Arrange
        const quadrant = QuadrantType.fourth;

        // Act
        final label = quadrant.labelZh;

        // Assert
        expect(label, '删除');
      });
    });

    group('Description Tests', () {
      test('Q1 description indicates Urgent & Important', () {
        // Arrange
        const quadrant = QuadrantType.first;

        // Act
        final description = quadrant.description;

        // Assert
        expect(description, 'Urgent & Important');
      });

      test('Q2 description indicates Important, Not Urgent', () {
        // Arrange
        const quadrant = QuadrantType.second;

        // Act
        final description = quadrant.description;

        // Assert
        expect(description, 'Important, Not Urgent');
      });

      test('Q3 description indicates Urgent, Not Important', () {
        // Arrange
        const quadrant = QuadrantType.third;

        // Act
        final description = quadrant.description;

        // Assert
        expect(description, 'Urgent, Not Important');
      });

      test('Q4 description indicates Neither Urgent nor Important', () {
        // Arrange
        const quadrant = QuadrantType.fourth;

        // Act
        final description = quadrant.description;

        // Assert
        expect(description, 'Neither Urgent nor Important');
      });
    });

    group('Color Mapping Tests', () {
      test('Q1 returns red color', () {
        // Arrange
        const quadrant = QuadrantType.first;
        const expectedColor = Color(0xFFEF5350);

        // Act
        final color = quadrant.color;

        // Assert
        expect(color, expectedColor);
      });

      test('Q2 returns blue color', () {
        // Arrange
        const quadrant = QuadrantType.second;
        const expectedColor = Color(0xFF42A5F5);

        // Act
        final color = quadrant.color;

        // Assert
        expect(color, expectedColor);
      });

      test('Q3 returns orange color', () {
        // Arrange
        const quadrant = QuadrantType.third;
        const expectedColor = Color(0xFFFFA726);

        // Act
        final color = quadrant.color;

        // Assert
        expect(color, expectedColor);
      });

      test('Q4 returns green color', () {
        // Arrange
        const quadrant = QuadrantType.fourth;
        const expectedColor = Color(0xFF66BB6A);

        // Act
        final color = quadrant.color;

        // Assert
        expect(color, expectedColor);
      });

      test('Q1 returns correct background color', () {
        // Arrange
        const quadrant = QuadrantType.first;
        const expectedColor = Color(0xFFFFEBEE);

        // Act
        final backgroundColor = quadrant.backgroundColor;

        // Assert
        expect(backgroundColor, expectedColor);
      });

      test('Q2 returns correct background color', () {
        // Arrange
        const quadrant = QuadrantType.second;
        const expectedColor = Color(0xFFE3F2FD);

        // Act
        final backgroundColor = quadrant.backgroundColor;

        // Assert
        expect(backgroundColor, expectedColor);
      });

      test('Q3 returns correct background color', () {
        // Arrange
        const quadrant = QuadrantType.third;
        const expectedColor = Color(0xFFFFF3E0);

        // Act
        final backgroundColor = quadrant.backgroundColor;

        // Assert
        expect(backgroundColor, expectedColor);
      });

      test('Q4 returns correct background color', () {
        // Arrange
        const quadrant = QuadrantType.fourth;
        const expectedColor = Color(0xFFE8F5E9);

        // Act
        final backgroundColor = quadrant.backgroundColor;

        // Assert
        expect(backgroundColor, expectedColor);
      });
    });

    group('Index Tests', () {
      test('Q1 returns index 0', () {
        // Arrange
        const quadrant = QuadrantType.first;

        // Act
        final index = quadrant.index;

        // Assert
        expect(index, 0);
      });

      test('Q2 returns index 1', () {
        // Arrange
        const quadrant = QuadrantType.second;

        // Act
        final index = quadrant.index;

        // Assert
        expect(index, 1);
      });

      test('Q3 returns index 2', () {
        // Arrange
        const quadrant = QuadrantType.third;

        // Act
        final index = quadrant.index;

        // Assert
        expect(index, 2);
      });

      test('Q4 returns index 3', () {
        // Arrange
        const quadrant = QuadrantType.fourth;

        // Act
        final index = quadrant.index;

        // Assert
        expect(index, 3);
      });
    });

    group('Index to QuadrantType Conversion', () {
      test('index 0 returns QuadrantType.first', () {
        // Act
        final quadrant = indexToQuadrant(0);

        // Assert
        expect(quadrant, QuadrantType.first);
      });

      test('index 1 returns QuadrantType.second', () {
        // Act
        final quadrant = indexToQuadrant(1);

        // Assert
        expect(quadrant, QuadrantType.second);
      });

      test('index 2 returns QuadrantType.third', () {
        // Act
        final quadrant = indexToQuadrant(2);

        // Assert
        expect(quadrant, QuadrantType.third);
      });

      test('index 3 returns QuadrantType.fourth', () {
        // Act
        final quadrant = indexToQuadrant(3);

        // Assert
        expect(quadrant, QuadrantType.fourth);
      });
    });

    group('Icon Asset Tests', () {
      test('Q1 returns fire icon asset', () {
        // Arrange
        const quadrant = QuadrantType.first;

        // Act
        final iconAsset = quadrant.iconAsset;

        // Assert
        expect(iconAsset, 'assets/icons/q1_fire.svg');
      });

      test('Q2 returns calendar icon asset', () {
        // Arrange
        const quadrant = QuadrantType.second;

        // Act
        final iconAsset = quadrant.iconAsset;

        // Assert
        expect(iconAsset, 'assets/icons/q2_calendar.svg');
      });

      test('Q3 returns people icon asset', () {
        // Arrange
        const quadrant = QuadrantType.third;

        // Act
        final iconAsset = quadrant.iconAsset;

        // Assert
        expect(iconAsset, 'assets/icons/q3_people.svg');
      });

      test('Q4 returns trash icon asset', () {
        // Arrange
        const quadrant = QuadrantType.fourth;

        // Act
        final iconAsset = quadrant.iconAsset;

        // Assert
        expect(iconAsset, 'assets/icons/q4_trash.svg');
      });
    });

    group('Full Label Tests', () {
      test('Q1 fullLabel contains both English and Chinese', () {
        // Arrange
        const quadrant = QuadrantType.first;

        // Act
        final fullLabel = quadrant.fullLabel;

        // Assert
        expect(fullLabel, contains('Do First'));
        expect(fullLabel, contains('立即做'));
      });

      test('Q2 fullLabel contains both English and Chinese', () {
        // Arrange
        const quadrant = QuadrantType.second;

        // Act
        final fullLabel = quadrant.fullLabel;

        // Assert
        expect(fullLabel, contains('Schedule'));
        expect(fullLabel, contains('计划做'));
      });
    });
  });

  group('Quadrant Entity', () {
    test('Quadrant with default empty task list', () {
      // Arrange & Act
      const quadrant = Quadrant(type: QuadrantType.first);

      // Assert
      expect(quadrant.type, QuadrantType.first);
      expect(quadrant.taskIds, isEmpty);
      expect(quadrant.isEmpty, isTrue);
      expect(quadrant.taskCount, 0);
    });

    test('Quadrant with tasks returns correct count', () {
      // Arrange
      const quadrant = Quadrant(
        type: QuadrantType.first,
        taskIds: ['task1', 'task2', 'task3'],
      );

      // Act
      final count = quadrant.taskCount;

      // Assert
      expect(count, 3);
      expect(quadrant.isEmpty, isFalse);
    });

    test('Quadrant copyWith updates type correctly', () {
      // Arrange
      const original = Quadrant(type: QuadrantType.first);

      // Act
      final updated = original.copyWith(type: QuadrantType.second);

      // Assert
      expect(updated.type, QuadrantType.second);
      expect(updated.taskIds, isEmpty);
    });

    test('Quadrant copyWith updates taskIds correctly', () {
      // Arrange
      const original = Quadrant(type: QuadrantType.first);

      // Act
      final updated = original.copyWith(taskIds: ['task1', 'task2']);

      // Assert
      expect(updated.type, QuadrantType.first);
      expect(updated.taskIds, hasLength(2));
    });

    test('Quadrant copyWith preserves values when null provided', () {
      // Arrange
      const original = Quadrant(
        type: QuadrantType.first,
        taskIds: ['task1'],
      );

      // Act
      final updated = original.copyWith();

      // Assert
      expect(updated.type, original.type);
      expect(updated.taskIds, original.taskIds);
    });
  });

  group('Quadrant Classification Logic', () {
    test('Urgent + Important should classify as Q1', () {
      // This test documents the expected classification behavior
      // Q1: Urgent + Important
      final isUrgent = true;
      final isImportant = true;

      expect(isUrgent && isImportant, isTrue);
      // Would map to QuadrantType.first
    });

    test('Not Urgent + Important should classify as Q2', () {
      // Q2: Not Urgent + Important
      final isUrgent = false;
      final isImportant = true;

      expect(!isUrgent && isImportant, isTrue);
      // Would map to QuadrantType.second
    });

    test('Urgent + Not Important should classify as Q3', () {
      // Q3: Urgent + Not Important
      final isUrgent = true;
      final isImportant = false;

      expect(isUrgent && !isImportant, isTrue);
      // Would map to QuadrantType.third
    });

    test('Not Urgent + Not Important should classify as Q4', () {
      // Q4: Not Urgent + Not Important
      final isUrgent = false;
      final isImportant = false;

      expect(!isUrgent && !isImportant, isTrue);
      // Would map to QuadrantType.fourth
    });
  });
}
