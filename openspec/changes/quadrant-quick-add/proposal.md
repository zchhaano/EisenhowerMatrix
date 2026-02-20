# Proposal: Quadrant Quick Add

## Why

Currently, users can only add tasks via the floating action button, which requires an extra step to select the target quadrant. Long-pressing on a quadrant to quickly add a task directly to that quadrant would reduce friction and make task creation more context-aware and efficient.

This aligns with mobile-first design principles where users expect contextual actions based on where they tap on the screen.

## What Changes

- Add long-press gesture detection on each quadrant card
- Show quick-add input dialog/modal when user long-presses a quadrant
- Pre-select the pressed quadrant as the target for the new task
- Support voice input and natural language parsing in the quick-add dialog
- Provide haptic feedback when long-press is detected
- Show visual indicator (ripple effect or highlight) during long-press

## Capabilities

### New Capabilities

None - this is an enhancement to existing quadrant management functionality.

### Modified Capabilities

- `quadrant-management`: Add requirement for contextual quick-add via long-press gesture on quadrants

## Impact

**Affected Files:**
- `lib/features/quadrant/presentation/widgets/quadrant_card.dart` - Add long-press gesture handling
- `lib/features/quadrant/presentation/widgets/quadrant_grid.dart` - Propagate long-press events
- `lib/features/quadrant/presentation/screens/home_screen.dart` - Handle quick-add callback
- `lib/features/quadrant/presentation/widgets/task_creation_modal.dart` - Support pre-selected quadrant

**User Experience:**
- Faster task creation workflow (one less tap)
- More intuitive interaction pattern
- Better mobile UX with contextual actions

**No Breaking Changes** - This is an additive feature that doesn't change existing behavior.
