# Tasks: Quadrant Quick Add

## 1. Widget Updates

- [x] 1.1 Add `onLongPress` callback parameter to `QuadrantCard` widget
- [x] 1.2 Add haptic feedback (`HapticFeedback.mediumImpact()`) on long-press trigger
- [x] 1.3 Add visual feedback animation (scale/overlay) during long-press gesture
- [x] 1.4 Wrap `QuadrantCard` content with `GestureDetector` for long-press detection

## 2. Grid Integration

- [x] 2.1 Add `onQuadrantLongPress` callback to `QuadrantGrid` widget
- [x] 2.2 Pass long-press callback from grid to each `QuadrantCard`
- [x] 2.3 Ensure long-press doesn't interfere with drag-to-resize functionality

## 3. Quick-Add Bottom Sheet

- [x] 3.1 Create `QuickAddBottomSheet` widget with text input field
- [x] 3.2 Add quadrant name display in bottom sheet header (e.g., "Add to Schedule")
- [x] 3.3 Implement save button to create task in selected quadrant
- [x] 3.4 Implement cancel/dismiss behavior
- [x] 3.5 Add keyboard submit (Enter key) to save task

## 4. Home Screen Integration

- [x] 4.1 Add `_handleQuickAdd(QuadrantType)` method to `HomeScreen`
- [x] 4.2 Connect `QuadrantGrid.onQuadrantLongPress` to show quick-add bottom sheet
- [x] 4.3 Wire quick-add save to `TaskListNotifier.createTask()`

## 5. Smart Input Integration

- [x] 5.1 Add voice input button to quick-add bottom sheet
- [x] 5.2 Integrate NLP parser for date/priority extraction in quick-add
- [x] 5.3 Support natural language input (reuse existing `NlpParser`)

## 6. Testing

- [x] 6.1 Add widget test for long-press gesture on `QuadrantCard`
- [x] 6.2 Add widget test for `QuickAddBottomSheet` component
- [x] 6.3 Add integration test for complete quick-add flow
- [x] 6.4 Test interaction with existing drag-to-resize feature

## 7. Polish

- [x] 7.1 Add accessibility labels for screen readers
- [x] 7.2 Ensure consistent styling with existing bottom sheets
- [x] 7.3 Add loading state during task creation
