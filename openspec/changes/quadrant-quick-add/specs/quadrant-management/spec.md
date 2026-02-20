# Quadrant Management Specification (Delta)

This delta spec adds contextual quick-add functionality to quadrant management.

## ADDED Requirements

### Requirement: Long-Press Quick Add
The system SHALL allow users to quickly add tasks to a specific quadrant by long-pressing on that quadrant.

#### Scenario: Long-press to add task to quadrant
- **WHEN** user long-presses on Quadrant 2 (Schedule)
- **THEN** quick-add dialog appears with Quadrant 2 pre-selected as the target

#### Scenario: Quick-add with title only
- **WHEN** user enters task title in quick-add dialog and taps Save
- **THEN** task is created immediately in the pre-selected quadrant

#### Scenario: Cancel quick-add
- **WHEN** user taps outside the quick-add dialog or presses Cancel
- **THEN** dialog dismisses without creating a task

#### Scenario: Haptic feedback on long-press
- **WHEN** user performs a successful long-press on a quadrant
- **THEN** system provides haptic feedback to confirm the gesture was recognized

#### Scenario: Visual feedback during long-press
- **WHEN** user starts pressing on a quadrant
- **THEN** quadrant shows visual feedback (scale/overlay) indicating the gesture is being recognized

### Requirement: Quick-Add Dialog Features
The system SHALL provide essential task creation features in the quick-add dialog.

#### Scenario: Pre-selected quadrant display
- **WHEN** quick-add dialog opens from long-press
- **THEN** dialog header shows the selected quadrant name (e.g., "Add to Schedule")

#### Scenario: Natural language input in quick-add
- **WHEN** user types "明天开会 高优" in quick-add
- **THEN** system parses date and priority, creates task with those attributes

#### Scenario: Voice input in quick-add
- **WHEN** user taps microphone icon in quick-add dialog
- **THEN** voice input mode activates for hands-free task creation

#### Scenario: Keyboard submit
- **WHEN** user presses Enter/Return key after entering task title
- **THEN** task is saved and dialog dismisses
