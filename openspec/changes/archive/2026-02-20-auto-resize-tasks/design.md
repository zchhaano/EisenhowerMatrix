## Context

Currently, the Eisenhower Matrix application displays tasks in quadrants using list views. As users add more tasks, the quadrant contents become scrollable, breaking the "single view overview" premise of the Eisenhower Matrix. Users have requested an auto-resizing mechanism to scale down task cards so they can see all their tasks in a quadrant simultaneously. Furthermore, while the current architecture supports managing tasks within quadrants, users need to be able to drag a task from one quadrant and drop it into another seamlessly.

## Goals / Non-Goals

**Goals:**
- Implement dynamic sizing for `TaskCard` widgets based on the number of tasks in a quadrant.
- Provide fluid drag-and-drop functionality that allows a task to be dragged from one quadrant and dropped onto another, effectively changing its quadrant assignment.
- Maintain readable text and interactable UI even when scaled down (up to a functional limit).

**Non-Goals:**
- Overhauling the entire persistence layer. We assume `TaskModel` and state management (e.g., Riverpod or Bloc) are already in place to handle quadrant updates.
- Deep customizations of the auto-resize algorithm (e.g., custom sizes for individual tasks). All tasks in a quadrant will scale uniformly.

## Decisions

1. **Auto-resizing Algorithm**:
   - We will utilize Flutter's `LayoutBuilder` inside the `QuadrantCard` to measure available height.
   - We can wrap the `TaskCard` list in a `ListView` (with disabled scrolling or bounded limits) and dynamically adjust the height of each `TaskCard` based on `(availableHeight - paddings) / taskCount`.
   - Alternatively, we can use `Transform.scale` or adjust constraints. We will adjust the font sizes and internal padding dynamically based on available height per item ensuring a minimum threshold constraint so text doesn't become completely illegible.

2. **Cross-Quadrant Drag and Drop**:
   - We will use Flutter's `Draggable` widget for `TaskCard` and `DragTarget` for `QuadrantCard`.
   - The State Management will handle updating the specific task's quadrant property when dropped on a new `DragTarget`.
   - The UI will provide visual feedback when dragging over a different quadrant.

## Risks / Trade-offs

- **Risk: Legibility bounds** -> **Mitigation**: Once tasks exceed a certain amount (e.g., >10 in a single quadrant), completely scaling them to fit might render them invisible. We'll implement a floor limit where scrollability will be enabled again if scaling becomes impractical.
- **Risk: Drag and Drop complex bounds** -> **Mitigation**: In mobile view where quadrants are in a swimlane, dragging to an off-screen quadrant might require edge-scrolling. If edge-scrolling is too complex, we will implement a "hover over edge to scroll" or mini-map drop zone in the future. For now, the focus is on cross-quadrant drag on tablet 2x2 layouts or adjacent swimlanes.
