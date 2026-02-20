## Why

As users add more tasks to a quadrant, tasks can easily exceed the visible screen space, requiring users to scroll. By dynamically resizing tasks so they all fit within a single quadrant, users can maintain a full overview of their tasks without scrolling. In addition, providing the ability to drag and drop tasks across different quadrants directly will significantly improve the user experience and task prioritization efficiency.

## What Changes

- Add an auto-resizing mechanism for tasks within a quadrant to fit as many as possible without scrolling.
- Allow tasks to shrink in size (e.g., reduce font size, padding, or hide secondary information like tags/dates) as the number of tasks in a quadrant increases.
- Provide a drag-and-drop interaction allowing users to long-press a task and drag it to another quadrant to instantly change its urgency/importance classification.

## Capabilities

### New Capabilities
- `auto-resize-tasks`: Dynamically adjust task sizes within a quadrant based on the total number of tasks to maintain visibility without scrolling.

### Modified Capabilities
- `quadrant-management`: Adding drag-and-drop task reassignment between different quadrants (Note: The spec already mentions this, but we will ensure it explicitly covers cross-quadrant drag and drop based on the new description).

## Impact

- **UI/UX**: Significant changes to `TaskCard` and `QuadrantCard` to support dynamic resizing logic.
- **Interactions**: Implementing cross-quadrant drag and drop might require lifting the state to a parent widget that oversees all four quadrants if it's not already structured this way.
- **Performance**: Dynamic calculation of sizes during layout might impact rendering performance if there are many tasks; needs optimization (e.g., using `LayoutBuilder` / `FittedBox`).
