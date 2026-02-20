# Inbox Review Specification

收件箱审查机制，通过Tinder式滑动交互实现快速任务分类。

## Purpose

This capability provides a Tinder-style swipe interface for rapid task classification. Users can quickly process unclassified and overdue tasks through intuitive swipe gestures, making daily review efficient and engaging.

## Requirements

### Requirement: Daily Review Flow
The system SHALL present unclassified and overdue tasks for daily review.

#### Scenario: Morning review prompt
- **WHEN** user opens app in the morning with unprocessed tasks
- **THEN** system prompts "Review X tasks to start your day"

#### Scenario: Access inbox anytime
- **WHEN** user taps inbox icon
- **THEN** system shows all unclassified and overdue tasks

#### Scenario: Empty inbox celebration
- **WHEN** user completes review and inbox is empty
- **THEN** system shows celebration animation and awards bonus points

### Requirement: Tinder-Style Swipe Actions
The system SHALL support swipe gestures for rapid task classification.

#### Scenario: Swipe up - Do First
- **WHEN** user swipes task card upward
- **THEN** task moves to Quadrant 1 (Do First)

#### Scenario: Swipe down - Delete
- **WHEN** user swipes task card downward
- **THEN** task is marked for deletion (moves to trash)

#### Scenario: Swipe left - Delegate
- **WHEN** user swipes task card left
- **THEN** task moves to Quadrant 3 (Delegate)

#### Scenario: Swipe right - Schedule
- **WHEN** user swipes task card right
- **THEN** task moves to Quadrant 2 (Schedule)

#### Scenario: Undo swipe
- **WHEN** user taps undo within 3 seconds of swipe
- **THEN** task returns to review queue

### Requirement: Overdue Task Handling
The system SHALL provide special handling for overdue tasks.

#### Scenario: Overdue task highlight
- **WHEN** task is past due date
- **THEN** task appears in review queue with red "Overdue" badge

#### Scenario: Overdue task options
- **WHEN** user reviews overdue task
- **THEN** system offers options: Do Today, Reschedule, Delegate, Delete

#### Scenario: Auto-archive ancient tasks
- **WHEN** task is overdue by more than 30 days
- **THEN** system prompts user to archive or delete

### Requirement: Batch Operations
The system SHALL support batch processing of multiple tasks.

#### Scenario: Select multiple tasks
- **WHEN** user long-presses to enter selection mode
- **THEN** user can select multiple tasks for batch action

#### Scenario: Batch classify
- **WHEN** user selects multiple tasks and chooses quadrant
- **THEN** all selected tasks move to chosen quadrant

#### Scenario: Batch delete
- **WHEN** user selects multiple tasks and chooses delete
- **THEN** all selected tasks move to trash after confirmation

### Requirement: Review Statistics
The system SHALL track and display review performance metrics.

#### Scenario: Show review stats
- **WHEN** user completes review session
- **THEN** system shows "Reviewed X tasks in Y seconds"

#### Scenario: Streak tracking
- **WHEN** user completes daily review for consecutive days
- **THEN** system displays review streak counter

### Requirement: Accessibility Support
The system SHALL ensure review flow is accessible to all users.

#### Scenario: VoiceOver/TalkBack support
- **WHEN** user enables screen reader
- **THEN** swipe actions are announced with clear descriptions

#### Scenario: Keyboard navigation
- **WHEN** user navigates via keyboard
- **THEN** arrow keys and shortcuts perform swipe-equivalent actions
