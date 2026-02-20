# Quadrant Management Specification (Delta)

## MODIFIED Requirements

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
