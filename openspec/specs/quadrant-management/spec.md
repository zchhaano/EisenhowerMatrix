# Quadrant Management Specification

四象限任务管理核心功能，基于艾森豪威尔矩阵实现任务的优先级分类与管理。

## Purpose

This capability provides the core task management functionality based on the Eisenhower Matrix methodology. Users can organize tasks into four quadrants based on urgency and importance, enabling effective prioritization and time management.

## Requirements

### Requirement: Task CRUD Operations
The system SHALL allow users to create, read, update, and delete tasks within the four quadrants.

#### Scenario: Create new task
- **WHEN** user creates a task with title "Prepare quarterly report"
- **THEN** system creates task and places it in the specified quadrant

#### Scenario: Update task details
- **WHEN** user modifies task title or description
- **THEN** system updates task and syncs changes

#### Scenario: Delete task
- **WHEN** user deletes a task
- **THEN** system removes task and moves to trash (soft delete) for 30 days

#### Scenario: Restore deleted task
- **WHEN** user restores task from trash within 30 days
- **THEN** task returns to its original quadrant

### Requirement: Four Quadrant Classification
The system SHALL classify all tasks into exactly one of four quadrants based on urgency and importance.

#### Scenario: Quadrant 1 - Do First
- **WHEN** task is marked as urgent AND important
- **THEN** system places task in Quadrant 1 (Do First / 立即做)

#### Scenario: Quadrant 2 - Schedule
- **WHEN** task is marked as important but NOT urgent
- **THEN** system places task in Quadrant 2 (Schedule / 计划做)

#### Scenario: Quadrant 3 - Delegate
- **WHEN** task is marked as urgent but NOT important
- **THEN** system places task in Quadrant 3 (Delegate / 委派做)

#### Scenario: Quadrant 4 - Delete
- **WHEN** task is marked as NOT urgent AND NOT important
- **THEN** system places task in Quadrant 4 (Delete / 删除)

### Requirement: Drag and Drop Between Quadrants
The system SHALL support intuitive drag-and-drop interaction to move tasks between quadrants and within the same quadrant.

#### Scenario: Move task between quadrants
- **WHEN** user long-presses a task from Quadrant 2 to drag it and drops it in Quadrant 1
- **THEN** task dynamically detaches, visually moves to Quadrant 1, and updates its underlying data to reflect the new urgency and importance with haptic/visual feedback

#### Scenario: Reorder within quadrant
- **WHEN** user drags task to new position within same quadrant
- **THEN** task order updates accordingly

#### Scenario: Edge scrolling during drag
- **WHEN** user drags a task near the edge of the screen in mobile swimlane view
- **THEN** swimlane automatically scrolls to the adjacent quadrant to allow cross-quadrant drag and drop

### Requirement: Subtask Support
The system SHALL allow tasks to have nested subtasks for complex task decomposition.

#### Scenario: Create subtask
- **WHEN** user adds subtask to parent task "Prepare presentation"
- **THEN** subtask appears indented under parent task

#### Scenario: Complete subtask
- **WHEN** user completes all subtasks of a parent
- **THEN** parent task shows progress indicator (e.g., 3/3 completed)

#### Scenario: Subtask inheritance
- **WHEN** subtask is created without explicit quadrant
- **THEN** subtask inherits parent's quadrant assignment

### Requirement: Task Attributes
The system SHALL support essential task attributes including title, description, due date, priority, and tags.

#### Scenario: Set due date
- **WHEN** user sets due date for task
- **THEN** system displays date and sends reminder notification

#### Scenario: Add tags
- **WHEN** user adds tags "work" and "urgent" to task
- **THEN** tags are displayed and task is filterable by tags

#### Scenario: Set priority level
- **WHEN** user sets priority to "High"
- **THEN** task displays priority indicator and sorts higher in list

### Requirement: Task Status Management
The system SHALL track task completion status and provide completion workflows.

#### Scenario: Mark task complete
- **WHEN** user marks task as complete
- **THEN** task shows strikethrough, moves to completed section, awards points

#### Scenario: Mark task incomplete
- **WHEN** user uncompletes a task
- **THEN** task returns to active state in original quadrant

### Requirement: Mobile-Optimized Swimlane View
The system SHALL display quadrants in a horizontally-scrollable swimlane layout optimized for mobile devices.

#### Scenario: Horizontal swipe navigation
- **WHEN** user swipes left/right on mobile
- **THEN** view scrolls to adjacent quadrant

#### Scenario: Single-handed operation
- **WHEN** user interacts with app using one hand
- **THEN** all primary actions are reachable within thumb zone

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
