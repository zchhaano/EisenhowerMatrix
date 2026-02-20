# Design: Quadrant Quick Add

## Context

The Eisenhower Matrix app currently provides task creation via a floating action button (FAB). Users tap the FAB, then select a quadrant in the modal. This requires 2 taps minimum to create a task in a specific quadrant.

Mobile users expect contextual interactions - long-press is a standard gesture for revealing additional actions on mobile platforms (iOS and Android).

**Current Flow:**
```
Tap FAB → Modal opens → Select quadrant → Enter task title → Save
```

**New Flow:**
```
Long-press quadrant → Quick-add modal opens (quadrant pre-selected) → Enter task title → Save
```

## Goals / Non-Goals

**Goals:**
- Add long-press gesture detection on quadrant cards
- Show quick-add dialog with pre-selected quadrant
- Provide haptic feedback for tactile confirmation
- Maintain backward compatibility with existing FAB flow

**Non-Goals:**
- Replace the existing FAB task creation flow
- Add complex task editing in quick-add (keep it simple - title only)
- Support subtask creation in quick-add (use full modal for that)

## Decisions

### 1. Gesture Detection Layer

**Decision:** Add `GestureDetector` with `onLongPress` to `QuadrantCard` widget.

**Alternatives Considered:**
- `InkWell` with `onLongPress` - Provides ripple effect but less control over visual feedback
- `Listener` with raw gesture handling - Overkill for simple long-press

**Rationale:** `GestureDetector` is lightweight and gives us control to add custom visual feedback during the long-press.

### 2. Quick-Add Dialog vs Bottom Sheet

**Decision:** Use a bottom sheet for quick-add.

**Alternatives Considered:**
- Dialog modal - Blocks too much screen space, less mobile-friendly
- Inline text field - Could disrupt quadrant layout

**Rationale:** Bottom sheets are mobile-friendly, support keyboard input well, and can include smart input features (voice, NLP) if needed.

### 3. Callback Propagation

**Decision:** Add `onLongPress` callback to `QuadrantCard` and propagate through `QuadrantGrid` to `HomeScreen`.

**Rationale:** Follows Flutter's callback pattern. `HomeScreen` already handles task creation via the FAB, so it's the right place to handle quick-add logic.

### 4. Haptic Feedback

**Decision:** Use `HapticFeedback.mediumImpact()` on long-press trigger.

**Rationale:** Medium impact provides clear tactile confirmation without being too aggressive. Light impact might be missed, heavy impact feels jarring.

### 5. Visual Feedback During Long-Press

**Decision:** Show a subtle scale animation and color overlay during long-press before the action triggers.

**Rationale:** Gives users visual indication that their gesture is being recognized before the 500ms threshold.

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| Long-press might interfere with scrolling/dragging | Ensure gesture recognizer distinguishes between long-press and drag gestures |
| Users might not discover the feature | Add a hint in onboarding or empty state; consider tooltip on first use |
| Accidental triggers | Require clear long-press (500ms+), not a tap-and-hold during scroll |
| Inconsistent with iOS/Android conventions | Follow platform HIG/Material guidelines for long-press behavior |

## Implementation Overview

```
QuadrantCard (widget)
├── GestureDetector (onLongPress callback)
│   └── Visual feedback (scale animation)
│
QuadrantGrid (widget)
├── onQuadrantLongPress callback
│
HomeScreen (screen)
├── _handleQuickAdd(QuadrantType)
├── Shows QuickAddBottomSheet
│   ├── TextField (task title)
│   ├── Voice input button
│   └── Save/Cancel actions
```

## Open Questions

None - design is straightforward and well-defined.
