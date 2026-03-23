"""
🐝 BusyBee ML Models - Domain-Specific Implementations
======================================================

This file contains specific ML model implementations for each of the 12 life domains.
Each model is designed to work with the BusyBee data schema and provides actionable insights.

Author: BusyBee ML Team
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum

# ML Libraries (would be installed in production)
# from sklearn.ensemble import GradientBoostingClassifier, GradientBoostingRegressor
# from sklearn.preprocessing import StandardScaler, LabelEncoder

# =============================================================================
# SHARED UTILITIES
# =============================================================================

class Domain(str, Enum):
    HEALTH = "health"
    FINANCE = "finance"
    GOALS = "goals"
    HABITS = "habits"
    CAREER = "career"
    RELATIONSHIPS = "relationships"
    EDUCATION = "education"
    MINDSET = "mindset"
    SPIRITUALITY = "spirituality"
    FAMILY = "family"
    RECREATION = "recreation"
    TRAVEL = "travel"


@dataclass
class ModelPrediction:
    """Standard prediction output format"""
    prediction: float
    confidence: float
    recommendation: str
    model_version: str
    features_used: List[str]


# =============================================================================
# 🏥 HEALTH DOMAIN MODELS
# =============================================================================

class HealthWorkoutRecommender:
    """
    Recommends optimal workout types based on user's history, energy levels, and schedule.
    
    Target: Predict best workout type for a given day
    
    Features:
    - Historical workout patterns
    - Time of day preferences
    - Day of week
    - Recent workout intensity
    - Sleep quality
    - Energy levels
    
    Model: Gradient Boosting Classifier
    """
    
    MODEL_VERSION = "1.0.0"
    
    WORKOUT_TYPES = [
        'cardio', 'strength', 'hiit', 'yoga', 'running',
        'swimming', 'cycling', 'stretching', 'sports', 'rest'
    ]
    
    def predict(self, user_health_data: dict) -> ModelPrediction:
        """
        Recommend best workout for today.
        
        Args:
            user_health_data: Dict with keys like:
                - energy_level (1-10)
                - sleep_quality (1-10)
                - workout_frequency_7d (int)
                - day_of_week (0-6)
                - recent_intensity (1-10)
                - hours_since_last_workout (int)
        
        Returns:
            ModelPrediction with recommendation
        """
        
        # Extract features
        energy = user_health_data.get('energy_level', 7)
        sleep = user_health_data.get('sleep_quality', 7)
        freq_7d = user_health_data.get('workout_frequency_7d', 3)
        intensity = user_health_data.get('recent_intensity', 5)
        hours_rest = user_health_data.get('hours_since_last_workout', 24)
        
        # Rule-based prediction (would be ML model in production)
        if sleep < 4 or energy < 3:
            prediction = 'rest'
            confidence = 0.9
        elif hours_rest < 12:
            prediction = 'light_activity'
            confidence = 0.7
        elif energy > 7 and intensity < 6:
            prediction = 'hiit'
            confidence = 0.75
        elif energy > 5 and freq_7d < 4:
            prediction = 'strength'
            confidence = 0.7
        elif energy > 6:
            prediction = 'cardio'
            confidence = 0.65
        else:
            prediction = 'yoga'
            confidence = 0.6
        
        # Generate recommendation
        recommendations = {
            'rest': "🛌 Your body needs recovery. Take a rest day!",
            'light_activity': "🚶 Light activity only - try walking or stretching.",
            'hiit': "🔥 High energy! Perfect for an intense HIIT session!",
            'strength': "💪 Great for strength training today!",
            'cardio': "🏃 Energy is high - go for a run or swim!",
            'yoga': "🧘 Good balance - try yoga for mind and body."
        }
        
        return ModelPrediction(
            prediction=prediction,
            confidence=confidence,
            recommendation=recommendations.get(prediction, "Stay active!"),
            model_version=self.MODEL_VERSION,
            features_used=['energy_level', 'sleep_quality', 'workout_frequency_7d']
        )


class SleepQualityPredictor:
    """
    Predicts sleep quality and suggests improvements.
    
    Target: Predict sleep quality score (1-10)
    
    Features:
    - Bedtime consistency
    - Screen time before bed
    - Exercise timing
    - Caffeine intake
    - Stress levels
    
    Model: Gradient Boosting Regressor
    """
    
    MODEL_VERSION = "1.0.0"
    
    def predict(self, context: dict) -> ModelPrediction:
        """Predict sleep quality"""
        
        # Extract features
        bedtime_std = context.get('bedtime_consistency', 1.0)  # hours std dev
        screen_time = context.get('screen_time_minutes', 60)
        caffeine_mg = context.get('caffeine_mg_today', 0)
        stress = context.get('stress_level', 5)
        exercise_today = context.get('exercise_today', False)
        exercise_hour = context.get('hours_since_exercise', 8)
        
        # Calculate predicted quality (rule-based simulation)
        base_quality = 7.0
        
        # Bedtime consistency (-1 to +1)
        if bedtime_std > 2:
            base_quality -= 1.5
        elif bedtime_std < 1:
            base_quality += 0.5
        
        # Screen time
        if screen_time > 60:
            base_quality -= (screen_time - 60) / 30
        elif screen_time < 30:
            base_quality += 0.5
        
        # Caffeine
        if caffeine_mg > 200:
            base_quality -= 1.5
        elif caffeine_mg > 100:
            base_quality -= 0.5
        
        # Stress
        base_quality -= (stress - 5) * 0.3
        
        # Exercise timing
        if exercise_today and 4 <= exercise_hour <= 10:
            base_quality += 0.5
        elif exercise_today and exercise_hour < 4:
            base_quality -= 0.5  # Too close to bed
        
        # Clamp to 1-10
        prediction = max(1, min(10, base_quality))
        
        # Generate recommendations
        suggestions = []
        if bedtime_std > 1.5:
            suggestions.append("🌙 Try to maintain consistent bedtime")
        if screen_time > 30:
            suggestions.append("📱 Reduce screen time before bed")
        if caffeine_mg > 100:
            suggestions.append("☕ Limit caffeine after 2 PM")
        if stress > 7:
            suggestions.append("🧘 Consider meditation before sleep")
        
        if not suggestions:
            recommendation = f"✨ Great sleep habits! Predicted quality: {prediction:.1f}/10"
        else:
            recommendation = " | ".join(suggestions)
        
        return ModelPrediction(
            prediction=round(prediction, 1),
            confidence=0.8,
            recommendation=recommendation,
            model_version=self.MODEL_VERSION,
            features_used=['bedtime_consistency', 'screen_time', 'caffeine', 'stress']
        )


# =============================================================================
# 💰 FINANCE DOMAIN MODELS
# =============================================================================

class SpendingForecastModel:
    """
    Forecasts future spending patterns.
    
    Target: Predict spending amount for next month by category
    
    Features:
    - Historical spending by category
    - Day of month patterns
    - Seasonal factors
    - Income patterns
    
    Model: Gradient Boosting Regressor (per category)
    """
    
    MODEL_VERSION = "1.0.0"
    
    CATEGORIES = [
        'housing', 'food', 'transportation', 'utilities',
        'entertainment', 'shopping', 'healthcare', 'education',
        'savings', 'other'
    ]
    
    def predict(self, finance_data: list) -> Dict[str, ModelPrediction]:
        """Predict spending for all categories"""
        predictions = {}
        
        # Simulate predictions based on historical patterns
        for category in self.CATEGORIES:
            # In production, this would use trained model
            base_amount = 200  # Placeholder
            
            # Adjust based on day of month
            day = datetime.now().day
            if day < 10:
                multiplier = 0.7  # Month start - less spending
            elif day > 25:
                multiplier = 1.2  # Month end - bills
            else:
                multiplier = 1.0
            
            predicted = base_amount * multiplier
            
            predictions[category] = ModelPrediction(
                prediction=round(predicted, 2),
                confidence=0.75,
                recommendation=f"Projected {category}: ${predicted:.2f}",
                model_version=self.MODEL_VERSION,
                features_used=['historical_avg', 'day_of_month']
            )
        
        return predictions


class BudgetAnomalyDetector:
    """
    Detects unusual spending patterns.
    
    Target: Identify anomalous transactions
    
    Features:
    - Transaction amount vs category average
    - Time of transaction
    - Merchant deviation
    
    Model: Isolation Forest / Z-Score
    """
    
    MODEL_VERSION = "1.0.0"
    
    def __init__(self):
        self.category_stats = {}
    
    def detect(self, transactions: list) -> List[dict]:
        """Detect anomalies in transactions"""
        anomalies = []
        
        for tx in transactions:
            is_anomaly = False
            reasons = []
            
            # Check amount vs typical
            amount = tx.get('amount', 0)
            category = tx.get('category', 'other')
            typical = self.category_stats.get(category, {}).get('mean', 100)
            
            if amount > typical * 3:
                is_anomaly = True
                reasons.append(f"3x typical {category} spending")
            
            # Check time
            hour = tx.get('hour', 12)
            if hour < 5 or hour > 23:
                is_anomaly = True
                reasons.append("Unusual transaction time")
            
            if is_anomaly:
                anomalies.append({
                    'transaction_id': tx.get('id'),
                    'is_anomaly': True,
                    'reasons': reasons,
                    'amount': amount
                })
        
        return anomalies


# =============================================================================
# 🎯 GOALS DOMAIN MODELS
# =============================================================================

class GoalCompletionPredictor:
    """
    Predicts if a goal will be completed on time.
    
    Target: Probability of goal completion by target date
    
    Features:
    - Progress rate
    - Days remaining
    - Milestone completion rate
    - Category difficulty
    """
    
    MODEL_VERSION = "1.0.0"
    
    def predict(self, goal_data: dict) -> ModelPrediction:
        """Predict goal completion probability"""
        
        # Extract features
        progress = goal_data.get('progress', 0)
        target_date = goal_data.get('target_date')
        created_at = goal_data.get('created_at', datetime.now() - timedelta(days=30))
        
        # Calculate days
        if isinstance(target_date, str):
            target_date = datetime.fromisoformat(target_date.replace('Z', '+00:00'))
        
        days_remaining = (target_date - datetime.now()).days
        total_days = (target_date - datetime.now()).days + (datetime.now() - datetime.now()).days
        
        if days_remaining <= 0:
            probability = 1.0 if progress >= 100 else 0.1
        else:
            # Required daily progress
            remaining_progress = 100 - progress
            required_daily = remaining_progress / days_remaining
            
            # Base probability calculation
            if required_daily < 2:
                probability = 0.9
            elif required_daily < 5:
                probability = 0.7
            elif required_daily < 10:
                probability = 0.5
            else:
                probability = 0.3
        
        # Generate recommendations
        if probability < 0.4:
            recommendation = "⚠️ Goal at risk! Consider: breaking into smaller tasks, adjusting deadline, or getting support."
        elif probability < 0.7:
            recommendation = "💪 Achievable! Stay focused on daily progress."
        else:
            recommendation = "🎯 You're on track! Keep up the great work!"
        
        return ModelPrediction(
            prediction=probability,
            confidence=0.75,
            recommendation=recommendation,
            model_version=self.MODEL_VERSION,
            features_used=['progress', 'days_remaining', 'required_daily_rate']
        )


class MilestoneGenerator:
    """
    AI-generated milestone suggestions.
    
    Target: Suggest optimal milestones for a goal
    """
    
    MILESTONE_TEMPLATES = {
        'health': [
            'Complete initial assessment', 'Establish baseline',
            'Achieve 25% progress', 'Reach halfway point',
            'Final push preparation', 'Goal completion'
        ],
        'career': [
            'Research phase', 'Update materials', 'Submit applications',
            'Complete interviews', 'Receive offer', 'Accept position'
        ],
        'finance': [
            'Create budget', 'Track expenses', 'Identify savings',
            'Reach milestone 1', 'Reach milestone 2', 'Goal achieved'
        ],
        'education': [
            'Course overview', 'Complete module 1', 'Halfway point',
            'Practice exercises', 'Final prep', 'Complete certification'
        ],
        'general': [
            'Define objective', 'Initial planning', 'Research complete',
            'Mid-point review', 'Final push', 'Goal achieved'
        ]
    }
    
    def generate(self, goal_data: dict) -> List[dict]:
        """Generate milestone suggestions"""
        
        category = goal_data.get('category', 'general')
        template = self.MILESTONE_TEMPLATES.get(category, self.MILESTONE_TEMPLATES['general'])
        
        target_date = pd.to_datetime(goal_data.get('target_date', datetime.now() + timedelta(days=90)))
        total_days = (target_date - datetime.now()).days
        
        milestones = []
        for i, title in enumerate(template):
            due_date = datetime.now() + timedelta(days=int(total_days * (i + 1) / len(template)))
            
            milestones.append({
                'title': title,
                'description': f"Milestone {i+1} of {len(template)}",
                'due_date': due_date.isoformat(),
                'progress_target': int((i + 1) / len(template) * 100)
            })
        
        return milestones


# =============================================================================
# 🔄 HABITS DOMAIN MODELS
# =============================================================================

class StreakPredictor:
    """
    Predicts streak survival probability.
    
    Target: Probability of maintaining streak
    
    Features:
    - Current streak length
    - Time of day consistency
    - Historical patterns
    """
    
    MODEL_VERSION = "1.0.0"
    
    def predict(self, habit_data: dict, completion_history: list) -> ModelPrediction:
        """Predict streak survival for today"""
        
        current_streak = habit_data.get('current_streak', 0)
        
        # Calculate base probability (longer streaks = more likely to continue)
        if current_streak < 3:
            base_prob = 0.6
        elif current_streak < 7:
            base_prob = 0.75
        elif current_streak < 21:
            base_prob = 0.85
        elif current_streak < 66:
            base_prob = 0.92
        else:
            base_prob = 0.95
        
        # Adjust for time of day
        hour = datetime.now().hour
        if 6 <= hour <= 10:
            base_prob *= 1.03
        elif 20 <= hour <= 22:
            base_prob *= 1.02
        
        probability = min(0.99, base_prob)
        
        # Generate motivation
        if current_streak == 0:
            motivation = "🌱 Start your streak today!"
        elif current_streak < 7:
            motivation = f"🔥 {current_streak} day streak! Keep going!"
        elif current_streak < 21:
            motivation = f"💪 {current_streak} days strong! Building real habits!"
        elif current_streak < 66:
            motivation = f"⭐ {current_streak} days! You're becoming who you want to be!"
        else:
            motivation = f"🐝 {current_streak} days! You're absolutely unstoppable!"
        
        return ModelPrediction(
            prediction=probability,
            confidence=0.8,
            recommendation=motivation,
            model_version=self.MODEL_VERSION,
            features_used=['current_streak', 'time_of_day', 'historical_consistency']
        )


class HabitSuggestionEngine:
    """
    Suggests new habits based on user success patterns.
    """
    
    HABIT_TEMPLATES = {
        'health': [
            {'name': 'Morning stretch', 'duration': 10, 'time': 'morning'},
            {'name': 'Drink 8 glasses water', 'duration': 5, 'time': 'all_day'},
            {'name': '10 min workout', 'duration': 10, 'time': 'evening'},
            {'name': 'Evening walk', 'duration': 20, 'time': 'evening'},
        ],
        'mindset': [
            {'name': 'Morning gratitude', 'duration': 5, 'time': 'morning'},
            {'name': '5 min meditation', 'duration': 5, 'time': 'morning'},
            {'name': 'Journal entry', 'duration': 10, 'time': 'evening'},
        ],
        'education': [
            {'name': 'Read 10 pages', 'duration': 15, 'time': 'morning'},
            {'name': 'Language practice', 'duration': 15, 'time': 'workday'},
            {'name': 'Online course', 'duration': 20, 'time': 'evening'},
        ],
        'finance': [
            {'name': 'Log expenses', 'duration': 5, 'time': 'evening'},
            {'name': 'Check budget', 'duration': 5, 'time': 'morning'},
        ],
        'relationships': [
            {'name': 'Send appreciation', 'duration': 5, 'time': 'morning'},
            {'name': 'Call family', 'duration': 15, 'time': 'evening'},
        ]
    }
    
    def suggest(self, user_data: dict, existing_habits: list) -> List[dict]:
        """Suggest new habits"""
        
        suggestions = []
        existing_names = [h.get('name', '').lower() for h in existing_habits]
        
        for category, habits in self.HABIT_TEMPLATES.items():
            for habit in habits:
                if habit['name'].lower() not in existing_names:
                    suggestions.append({
                        'name': habit['name'],
                        'category': category,
                        'duration': habit['duration'],
                        'suggested_time': habit['time'],
                        'success_probability': 0.7,  # Would be ML predicted
                        'reason': f"Based on your {category} interests"
                    })
        
        return suggestions[:5]


# =============================================================================
# 💼 CAREER DOMAIN MODELS
# =============================================================================

class JobMatchingModel:
    """
    Matches job postings to user profile.
    """
    
    MODEL_VERSION = "1.0.0"
    
    def match(self, user_profile: dict, job: dict) -> ModelPrediction:
        """Calculate match score"""
        
        # Skills match
        user_skills = set(s.lower() for s in user_profile.get('skills', []))
        required = set(s.lower() for s in job.get('required_skills', []))
        
        if required:
            skills_score = len(user_skills & required) / len(required)
        else:
            skills_score = 0.8
        
        # Experience
        user_exp = user_profile.get('years_experience', 0)
        req_exp = job.get('required_years', 0)
        exp_score = 1.0 if user_exp >= req_exp else 0.5
        
        # Salary
        user_salary = user_profile.get('expected_salary', 50000)
        job_salary = job.get('salary_range', {}).get('mid', 50000)
        
        if job_salary > 0:
            salary_score = 1 - abs(user_salary - job_salary) / job_salary
        else:
            salary_score = 0.8
        
        # Weighted total
        total_score = skills_score * 0.4 + exp_score * 0.35 + salary_score * 0.25
        
        # Missing skills
        missing = required - user_skills
        
        if total_score >= 0.8:
            recommendation = "🎯 Strong match! Apply now!"
        elif total_score >= 0.6:
            recommendation = "👍 Good match. Consider applying!"
        else:
            recommendation = "⚠️ May need more experience."
        
        if missing:
            recommendation += f" 📚 Learn: {', '.join(list(missing)[:3])}"
        
        return ModelPrediction(
            prediction=total_score,
            confidence=0.8,
            recommendation=recommendation,
            model_version=self.MODEL_VERSION,
            features_used=['skills', 'experience', 'salary']
        )


# =============================================================================
# 👥 RELATIONSHIPS DOMAIN MODELS
# =============================================================================

class ContactReminderEngine:
    """
    Suggests when to reach out to contacts.
    """
    
    OPTIMAL_INTERVALS = {
        'family': 7,
        'partner': 3,
        'close_friend': 14,
        'friend': 30,
        'colleague': 30,
        'other': 60
    }
    
    def get_reminders(self, relationships: list, user_id: str) -> List[dict]:
        """Get contact reminders"""
        
        reminders = []
        
        for rel in relationships:
            if rel.get('user_id') != user_id:
                continue
            
            last_contact = rel.get('last_contact_date', datetime.now() - timedelta(days=365))
            if isinstance(last_contact, str):
                last_contact = datetime.fromisoformat(last_contact.replace('Z', '+00:00'))
            
            days_since = (datetime.now() - last_contact).days
            
            optimal = self.OPTIMAL_INTERVALS.get(rel.get('relationship_type', 'other'), 30)
            overdue = days_since - optimal
            
            if overdue > 0:
                urgency = min(1.0, overdue / optimal)
                
                reminders.append({
                    'name': rel['name'],
                    'relationship_type': rel['relationship_type'],
                    'days_since_contact': days_since,
                    'urgency_score': urgency,
                    'suggested_action': f"Reach out to {rel['name']}",
                    'priority': 'high' if urgency > 0.7 else 'medium'
                })
        
        return sorted(reminders, key=lambda x: x['urgency_score'], reverse=True)


# =============================================================================
# 📚 EDUCATION DOMAIN MODELS
# =============================================================================

class LearningPathRecommender:
    """
    Recommends learning paths based on goals.
    """
    
    LEARNING_PATHS = {
        'software_developer': {
            'duration_months': 6,
            'stages': [
                {'name': 'Fundamentals', 'courses': ['CS Basics', 'Python']},
                {'name': 'Frontend', 'courses': ['HTML/CSS', 'JavaScript', 'React']},
                {'name': 'Backend', 'courses': ['Node.js', 'Databases', 'APIs']},
                {'name': 'DevOps', 'courses': ['Git', 'Docker', 'CI/CD']}
            ]
        },
        'data_scientist': {
            'duration_months': 8,
            'stages': [
                {'name': 'Statistics', 'courses': ['Stats', 'Probability']},
                {'name': 'Python', 'courses': ['Python for Data', 'Pandas']},
                {'name': 'ML Basics', 'courses': ['ML Fundamentals', 'Sklearn']},
                {'name': 'Deep Learning', 'courses': ['PyTorch', 'TensorFlow']}
            ]
        }
    }
    
    def recommend(self, user_profile: dict, goal: str) -> dict:
        """Generate learning path"""
        
        goal_lower = goal.lower()
        
        # Match goal to path
        if 'developer' in goal_lower or 'engineer' in goal_lower:
            path = self.LEARNING_PATHS['software_developer']
        elif 'data' in goal_lower or 'ml' in goal_lower:
            path = self.LEARNING_PATHS['data_scientist']
        else:
            return {'error': 'No path found'}
        
        weekly_hours = user_profile.get('weekly_learning_hours', 10)
        speed = weekly_hours / 10
        
        return {
            'goal': goal,
            'total_duration': f"{path['duration_months'] / speed:.1f} months",
            'weekly_commitment': f"{weekly_hours} hours",
            'stages': [
                {
                    'name': stage['name'],
                    'courses': stage['courses'],
                    'duration': f"{1.5 / speed:.1f} months"
                }
                for stage in path['stages']
            ]
        }


# =============================================================================
# 🏆 GAMIFICATION MODELS
# =============================================================================

class XPRewardCalculator:
    """
    Calculates XP rewards for user actions.
    """
    
    BASE_REWARDS = {
        'habit_completion': 10,
        'milestone_complete': 50,
        'goal_complete': 100,
        'streak_7': 25,
        'streak_21': 75,
        'streak_66': 200,
        'streak_100': 500,
        'achievement': 50,
        'daily_login': 5
    }
    
    def calculate(self, action: str, context: dict) -> dict:
        """Calculate XP reward"""
        
        base = self.BASE_REWARDS.get(action, 10)
        
        # Difficulty multiplier
        difficulty = context.get('difficulty', 'medium')
        diff_mult = {'easy': 1.0, 'medium': 1.5, 'hard': 2.0}.get(difficulty, 1.0)
        
        # Streak bonus
        streak = context.get('streak', 0)
        streak_bonus = 0
        if streak >= 100:
            streak_bonus = 500
        elif streak >= 66:
            streak_bonus = 200
        elif streak >= 21:
            streak_bonus = 75
        elif streak >= 7:
            streak_bonus = 25
        
        total = int(base * diff_mult + streak_bonus)
        
        return {
            'base_xp': base,
            'multiplier': diff_mult,
            'streak_bonus': streak_bonus,
            'total_xp': total,
            'new_total': context.get('current_xp', 0) + total
        }


class LevelCalculator:
    """
    Calculates level based on XP.
    """
    
    LEVELS = [
        (1, 0, 'Newcomer'),
        (2, 1000, 'Beginner'),
        (3, 3500, 'Explorer'),
        (4, 8500, 'Adventurer'),
        (5, 18500, 'Achiever'),
        (6, 36000, 'Champion'),
        (7, 63500, 'Warrior'),
        (8, 103500, 'Elite'),
        (9, 158500, 'Master'),
        (10, 233500, 'Grandmaster'),
        (11, 333500, 'Legend'),
        (12, 463500, 'Mythic'),
        (13, 628500, 'Transcendent'),
        (14, 828500, 'Celestial'),
        (15, 1078500, 'Divine'),
        (16, 1378500, 'Transcendent')
    ]
    
    def calculate_level(self, xp: int) -> dict:
        """Calculate level from XP"""
        
        current = 1
        next_xp = 1000
        
        for level, threshold, title in self.LEVELS:
            if xp >= threshold:
                current = level
                next_xp = self.LEVELS[min(level, 15)][1]
        
        prev_xp = self.LEVELS[current - 1][1]
        progress = (xp - prev_xp) / (next_xp - prev_xp) * 100
        
        return {
            'level': current,
            'title': self.LEVELS[current - 1][2],
            'xp': xp,
            'xp_to_next': next_xp - xp,
            'progress': round(progress, 1)
        }


# =============================================================================
# MODEL REGISTRY
# =============================================================================

class BusyBeeModelRegistry:
    """Central registry for all BusyBee ML models."""
    
    def __init__(self):
        self.models = {
            # Health
            'health_workout_recommender': HealthWorkoutRecommender(),
            'sleep_quality_predictor': SleepQualityPredictor(),
            
            # Finance
            'spending_forecast': SpendingForecastModel(),
            'budget_anomaly_detector': BudgetAnomalyDetector(),
            
            # Goals
            'goal_completion_predictor': GoalCompletionPredictor(),
            'milestone_generator': MilestoneGenerator(),
            
            # Habits
            'streak_predictor': StreakPredictor(),
            'habit_suggester': HabitSuggestionEngine(),
            
            # Career
            'job_matcher': JobMatchingModel(),
            
            # Relationships
            'contact_reminder': ContactReminderEngine(),
            
            # Education
            'learning_path_recommender': LearningPathRecommender(),
            
            # Gamification
            'xp_calculator': XPRewardCalculator(),
            'level_calculator': LevelCalculator()
        }
    
    def get(self, name: str):
        return self.models.get(name)
    
    def list_all(self) -> List[str]:
        return list(self.models.keys())


# =============================================================================
# EXAMPLE USAGE
# =============================================================================

if __name__ == "__main__":
    registry = BusyBeeModelRegistry()
    
    print("🐝 BusyBee ML Models")
    print("=" * 50)
    print(f"Total models: {len(registry.list_all())}")
    print()
    
    # Example: Streak prediction
    streak_model = registry.get('streak_predictor')
    habit = {'current_streak': 15, 'longest_streak': 45}
    history = [{'completed_date': (datetime.now() - timedelta(days=i)).isoformat()} for i in range(15)]
    
    pred = streak_model.predict(habit, history)
    print(f"🔥 Streak Prediction: {pred.prediction:.1%}")
    print(f"   {pred.recommendation}")
    print()
    
    # Example: XP calculation
    xp = registry.get('xp_calculator')
    result = xp.calculate('habit_completion', {'difficulty': 'medium', 'streak': 15, 'current_xp': 5000})
    print(f"💰 XP Earned: {result['total_xp']} XP")
    print()
    
    # Example: Level calculation
    level = registry.get('level_calculator')
    info = level.calculate_level(15000)
    print(f"📊 Level: {info['level']} - {info['title']}")
    print(f"   Progress: {info['progress']}% to next level")
