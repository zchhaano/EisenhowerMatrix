## 1. Drag and Drop Architecture

- [x] 1.1 Update `QuadrantCard` to act as a `DragTarget<TaskModel>`
- [x] 1.2 Update `TaskCard` to be wrapped in a `LongPressDraggable<TaskModel>`
- [x] 1.3 Implement `onAccept` logic in `QuadrantCard` to update the dropped task's quadrant assignment in the state management layer

## 2. Dynamic Auto-Resizing

- [x] 2.1 Refactor `QuadrantCard` to wrap its task list in a `LayoutBuilder` to obtain maximum available height
- [x] 2.2 Implement scaling logic to calculate `TaskCard` size dynamically based on `availableHeight / taskCount`
- [x] 2.3 Add constraints or floor limits to ensure `TaskCard` remains legible (e.g., min height threshold) and falls back to scrolling when exceeded

## 3. UI/UX Refinements

- [x] 3.1 Update `TaskCard` internals to gracefully handle smaller heights (e.g., adapt font size, hide secondary details)
- [x] 3.2 Add visual feedback (highlight) when a draggable task is hovering over a valid `DragTarget` quadrant
- [x] 3.3 Add edge-scrolling support or ensure drag and drop works smoothly in the mobile horizontal swimlane view
