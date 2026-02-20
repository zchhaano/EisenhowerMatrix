# Auto Resize Tasks Specification

## ADDED Requirements

### Requirement: Auto-Resize Tasks in Quadrant
The system SHALL dynamically adjust the size of task cards within a quadrant to ensure all tasks are visible without scrolling, up to a minimum legibility threshold.

#### Scenario: Few tasks in a quadrant
- **WHEN** a quadrant contains 1-3 tasks
- **THEN** tasks display at their normal, default size with full padding and font sizes

#### Scenario: Many tasks in a quadrant
- **WHEN** a user adds 5 or more tasks to a single quadrant
- **THEN** the system dynamically reduces the height, padding, and font size of all tasks in that quadrant so they all fit on screen simultaneously

#### Scenario: Exceeding minimum threshold
- **WHEN** the number of tasks in a quadrant makes them smaller than the minimum legibility threshold (e.g., height < 30px)
- **THEN** the scaling stops and the quadrant becomes scrollable to maintain readability
