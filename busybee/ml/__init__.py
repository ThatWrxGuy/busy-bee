"""
🐝 BusyBee ML Models Package

Domain-specific ML implementations for all 12 life domains.
"""

from .models import (
    BusyBeeModelRegistry,
    ModelPrediction,
    # Health
    HealthWorkoutRecommender,
    SleepQualityPredictor,
    # Finance
    SpendingForecastModel,
    BudgetAnomalyDetector,
    # Goals
    GoalCompletionPredictor,
    MilestoneGenerator,
    # Habits
    StreakPredictor,
    HabitSuggestionEngine,
    # Career
    JobMatchingModel,
    # Relationships
    ContactReminderEngine,
    # Education
    LearningPathRecommender,
    # Gamification
    XPRewardCalculator,
    LevelCalculator
)

__all__ = [
    'BusyBeeModelRegistry',
    'ModelPrediction',
    'HealthWorkoutRecommender',
    'SleepQualityPredictor',
    'SpendingForecastModel',
    'BudgetAnomalyDetector',
    'GoalCompletionPredictor',
    'MilestoneGenerator',
    'StreakPredictor',
    'HabitSuggestionEngine',
    'JobMatchingModel',
    'ContactReminderEngine',
    'LearningPathRecommender',
    'XPRewardCalculator',
    'LevelCalculator'
]
