# Gamification Specification

游戏化激励系统，通过积分、连胜和成就机制提升用户留存和执行动力。

## Purpose

This capability provides gamification features to enhance user engagement and motivation. Through points, streaks, achievements, and levels, users are incentivized to maintain productive habits and complete tasks consistently.

## Requirements

### Requirement: Productivity Points (Karma) System
The system SHALL award points for productive behaviors with quadrant-weighted scoring.

#### Scenario: Complete Q1 task
- **WHEN** user completes Quadrant 1 (Do First) task
- **THEN** system awards 10 points

#### Scenario: Complete Q2 task (bonus)
- **WHEN** user completes Quadrant 2 (Schedule) task
- **THEN** system awards 15 points (higher reward for strategic work)

#### Scenario: Complete Q3 task
- **WHEN** user completes Quadrant 3 (Delegate) task
- **THEN** system awards 5 points

#### Scenario: Delete Q4 task
- **WHEN** user deletes Quadrant 4 task (eliminating waste)
- **THEN** system awards 3 points for conscious elimination

#### Scenario: Points leaderboard
- **WHEN** user views profile
- **THEN** system displays total points and weekly ranking

### Requirement: Streak Tracking
The system SHALL track consecutive daily engagement and reward consistency.

#### Scenario: Daily check-in streak
- **WHEN** user opens app daily
- **THEN** streak counter increments, visual indicator shows current streak

#### Scenario: Streak bonus
- **WHEN** user reaches 7-day streak
- **THEN** system awards 50 bonus points

#### Scenario: Streak milestone celebrations
- **WHEN** user reaches 30/60/90 day streaks
- **THEN** system shows celebration animation and awards badge

#### Scenario: Streak freeze
- **WHEN** user is about to lose streak (hasn't opened app)
- **THEN** system sends reminder notification with streak at stake

### Requirement: Achievement System
The system SHALL award achievements for reaching milestones and demonstrating productive behaviors.

#### Scenario: First task completion
- **WHEN** user completes first task
- **THEN** system awards "Getting Started" achievement

#### Scenario: Clear 100 tasks
- **WHEN** user completes 100th task
- **THEN** system awards "Century Club" achievement

#### Scenario: Q2 champion
- **WHEN** user completes 50 Q2 tasks in a month
- **THEN** system awards "Strategic Thinker" badge

#### Scenario: Early bird
- **WHEN** user completes daily review before 8am for a week
- **THEN** system awards "Early Bird" achievement

### Requirement: Hardcore Mode
The system SHALL offer optional "hardcore mode" for users seeking greater accountability.

#### Scenario: Enable hardcore mode
- **WHEN** user enables hardcore mode
- **THEN** tasks cannot be moved to "later" quadrants after 10am

#### Scenario: Hardcore completion bonus
- **WHEN** user completes all daily tasks in hardcore mode
- **THEN** system awards 2x points multiplier

#### Scenario: Hardcore failure
- **WHEN** user fails to complete tasks in hardcore mode
- **THEN** streak resets and points are deducted

### Requirement: Level System
The system SHALL provide a progression system based on cumulative points.

#### Scenario: Level up
- **WHEN** user accumulates enough points
- **THEN** user advances to next level with celebration animation

#### Scenario: Level-based unlocks
- **WHEN** user reaches certain levels
- **THEN** new themes, icons, or features unlock

### Requirement: Social Comparison (Optional)
The system MAY allow users to compare progress with friends anonymously.

#### Scenario: Friend leaderboard
- **WHEN** user connects with friends
- **THEN** weekly points comparison shows relative performance

#### Scenario: Privacy controls
- **WHEN** user disables social features
- **THEN** no data is shared or visible to others

### Requirement: Anti-Gaming Measures
The system SHALL detect and prevent exploitation of gamification mechanics.

#### Scenario: Rapid task creation detection
- **WHEN** user creates and completes many trivial tasks rapidly
- **THEN** system reduces point awards and shows gentle warning

#### Scenario: Task quality weighting
- **WHEN** task has very short title (< 5 characters)
- **THEN** reduced points awarded upon completion
