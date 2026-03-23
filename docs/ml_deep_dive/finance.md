# 💰 Finance Domain - ML Deep Dive

This document provides comprehensive technical details for the Finance ML models.

---

## 1. Problem Definition

### 1.1 Core Problems to Solve

| Problem | Description | ML Task |
|---------|-------------|---------|
| **Spending Forecast** | Predict future spending by category | Time Series Regression |
| **Anomaly Detection** | Identify unusual transactions | Anomaly Detection |
| **Budget Optimization** | Suggest optimal budget allocation | Recommendation |
| **Savings Prediction** | Predict ability to save | Regression |
| **Bill Prediction** | Predict upcoming recurring bills | Pattern Recognition |

### 1.2 Data Sources

```sql
-- Main finance table structure
SELECT 
    id,
    user_id,
    date,
    transaction_type,  -- 'income', 'expense', 'investment', 'savings'
    category,          -- 'food', 'housing', 'transportation', etc.
    amount,
    description,
    account_name,
    created_at
FROM finance_entries
```

---

## 2. Spending Forecast Model

### 2.1 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    SPENDING FORECAST ARCHITECTURE                │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │  Raw Data    │───▶│   Feature    │───▶│    Model     │      │
│  │  (SQL)       │    │   Engine     │    │   Ensemble   │      │
│  └──────────────┘    └──────────────┘    └──────┬───────┘      │
│                                                  │              │
│  ┌──────────────┐    ┌──────────────┐           │              │
│  │  Calendar    │───▶│   External   │───────────┘              │
│  │  Features    │    │   Data       │                          │
│  └──────────────┘    └──────────────┘                          │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Feature Engineering

```python
# Feature categories for spending forecast

TEMPORAL_FEATURES = {
    'day_of_month': 'Day 1-31',
    'day_of_week': 'Monday=0, Sunday=6',
    'is_weekend': 'Binary weekend flag',
    'is_payday': 'Binary payday flag (1, 15, 30)',
    'days_from_payday': 'Signed days from nearest payday',
    'week_of_month': '1-5 week number',
    'is_month_start': 'Days 1-7',
    'is_month_end': 'Days 25-31',
    'quarter': 'Q1-Q4',
    'is_holiday': 'Holiday flag',
    'days_to_holiday': 'Days until next holiday'
}

HISTORICAL_FEATURES = {
    'mean_7d': 'Average daily spend last 7 days',
    'mean_30d': 'Average daily spend last 30 days',
    'mean_90d': 'Average daily spend last 90 days',
    'std_7d': 'Standard deviation 7 days',
    'std_30d': 'Standard deviation 30 days',
    'trend_7d': 'Linear trend coefficient 7 days',
    'trend_30d': 'Linear trend coefficient 30 days',
    'max_single_7d': 'Max single transaction 7 days',
    'transaction_count_7d': 'Number of transactions 7 days',
    'last_amount': 'Amount of last transaction',
    'last_transaction_days_ago': 'Days since last transaction'
}

USER_BEHAVIOR_FEATURES = {
    'total_income_30d': 'Total income last 30 days',
    'total_expense_30d': 'Total expenses last 30 days',
    'savings_rate_30d': 'Savings rate (income - expense) / income',
    'spending_velocity': 'Average daily spending rate',
    'budget_remaining': 'Budget remaining this month',
    'overspend_count_30d': 'Times over budget last 30 days'
}
```

### 2.3 Model Selection

```python
# Primary model: Gradient Boosting Ensemble

SPENDING_FORECAST_MODELS = {
    'primary': {
        'model': 'GradientBoostingRegressor',
        'params': {
            'n_estimators': 200,
            'max_depth': 6,
            'learning_rate': 0.05,
            'min_samples_split': 20,
            'min_samples_leaf': 10,
            'subsample': 0.8,
            'random_state': 42
        },
        'rationale': 'Handles non-linear relationships, robust to outliers'
    },
    
    'secondary': {
        'model': 'LinearRegression',
        'params': {
            'fit_intercept': True,
            'positive': True
        },
        'rationale': 'Interpretable baseline, ensures non-negative'
    },
    
    'tertiary': {
        'model': 'RandomForestRegressor',
        'params': {
            'n_estimators': 100,
            'max_depth': 8,
            'min_samples_leaf': 5,
            'random_state': 42
        },
        'rationale': 'Captures complex interactions'
    }
}

# Final prediction: Weighted ensemble
def ensemble_predict(X):
    gb_pred = gb_model.predict(X)
    lr_pred = lr_model.predict(X)
    rf_pred = rf_model.predict(X)
    
    # Weighted average
    final_pred = 0.5 * gb_pred + 0.2 * lr_pred + 0.3 * rf_pred
    
    return max(0, final_pred)  # Ensure non-negative
```

---

## 3. Anomaly Detection Model

### 3.1 Anomaly Types

| Type | Example | Detection Method |
|------|---------|------------------|
| **Amount** | $500 coffee | Z-score > 3 |
| **Time** | 3AM grocery | Outside typical hours |
| **Frequency** | 5 tx in 1 hour | Unusual pattern |
| **Category** | $2000 entertainment | Exceeds threshold |
| **Merchant** | First-time + high amount | New merchant check |

### 3.2 Multi-Layer Detection

```python
class AnomalyDetectionSystem:
    """
    Layered anomaly detection combining multiple methods.
    """
    
    def __init__(self):
        # Layer 1: Statistical (fast, simple)
        self.statistical_detector = StatisticalAnomalyDetector()
        
        # Layer 2: Machine Learning
        self.ml_detector = MLAnomalyDetector()
        
        # Layer 3: Rule-based (domain knowledge)
        self.rule_detector = RuleBasedDetector()
        
        # Layer 4: Peer comparison
        self.peer_detector = PeerComparisonDetector()
    
    def detect(self, transaction: Transaction) -> AnomalyReport:
        """Run all detection layers and combine results."""
        
        results = []
        
        # Layer 1: Statistical
        stat_result = self.statistical_detector.check(transaction)
        if stat_result.is_anomaly:
            results.append(stat_result)
        
        # Layer 2: ML
        ml_result = self.ml_detector.check(transaction)
        if ml_result.is_anomaly:
            results.append(ml_result)
        
        # Layer 3: Rules
        rule_result = self.rule_detector.check(transaction)
        if rule_result.is_anomaly:
            results.append(rule_result)
        
        # Layer 4: Peer
        peer_result = self.peer_detector.check(transaction)
        if peer_result.is_anomaly:
            results.append(peer_result)
        
        # Combine with weighted voting
        final_decision = self.combine_results(results)
        
        return AnomalyReport(
            is_anomaly=final_decision.is_anomaly,
            confidence=final_decision.confidence,
            anomalies=results,
            recommendation=final_decision.recommendation
        )
```

### 3.3 Statistical Detection (Layer 1)

```python
class StatisticalAnomalyDetector:
    """
    Statistical methods: Z-score, IQR, modified Z-score.
    """
    
    def calculate_category_stats(self, transactions: List[Transaction]):
        """Calculate statistics per category."""
        
        for category in set(t.category for t in transactions):
            cat_tx = [t.amount for t in transactions if t.category == category]
            
            self.category_stats[category] = {
                'mean': np.mean(cat_tx),
                'std': np.std(cat_tx),
                'median': np.median(cat_tx),
                'q1': np.percentile(cat_tx, 25),
                'q3': np.percentile(cat_tx, 75),
                'iqr': np.percentile(cat_tx, 75) - np.percentile(cat_tx, 25),
                'p95': np.percentile(cat_tx, 95),
                'p99': np.percentile(cat_tx, 99)
            }
    
    def check(self, transaction: Transaction) -> DetectionResult:
        """Check for statistical anomalies."""
        
        stats = self.category_stats.get(transaction.category)
        if not stats:
            return DetectionResult(is_anomaly=False, confidence=0)
        
        # Z-score method
        z_score = abs(transaction.amount - stats['mean']) / (stats['std'] + 1)
        
        # IQR method
        upper_fence = stats['q3'] + 1.5 * stats['iqr']
        lower_fence = stats['q1'] - 1.5 * stats['iqr']
        
        is_anomaly = z_score > 3 or transaction.amount > upper_fence
        
        return DetectionResult(
            is_anomaly=is_anomaly,
            confidence=min(0.95, 0.5 + z_score * 0.15) if is_anomaly else 0,
            reasons=[f"Z-score: {z_score:.1f}"] if z_score > 3 else [],
            method='statistical'
        )
```

### 3.4 ML Detection (Layer 2)

```python
class MLAnomalyDetector:
    """
    Machine learning: Isolation Forest + Local Outlier Factor.
    """
    
    def __init__(self):
        self.iso_forest = IsolationForest(
            contamination=0.05,
            random_state=42,
            n_estimators=100
        )
        
        self.lof = LocalOutlierFactor(
            n_neighbors=20,
            contamination=0.05
        )
    
    def _extract_features(self, transactions: List[Transaction]) -> np.ndarray:
        """Extract features for ML model."""
        
        features = []
        for tx in transactions:
            features.append([
                np.log1p(tx.amount),  # Log transform
                tx.hour,
                tx.day_of_week,
                tx.category_encoded,
                tx.is_recurring,
                tx.merchant_known
            ])
        
        return np.array(features)
    
    def check(self, transaction: Transaction) -> DetectionResult:
        """Check for ML-based anomalies."""
        
        X = self._extract_features([transaction])
        
        iso_pred = self.iso_forest.predict(X)[0]
        iso_score = self.iso_forest.score_samples(X)[0]
        
        is_anomaly = iso_pred == -1
        confidence = min(0.95, -iso_score)
        
        return DetectionResult(
            is_anomaly=is_anomaly,
            confidence=confidence if is_anomaly else 0,
            reasons=['ML flagged as anomaly'] if is_anomaly else [],
            method='ml'
        )
```

---

## 4. Budget Optimization Model

### 4.1 Problem

```
┌─────────────────────────────────────────────────────────────────┐
│                 BUDGET OPTIMIZATION                               │
│  INPUT:                                                          │
│  • Monthly income: $5,000                                        │
│  • Fixed expenses: $2,000                                        │
│  • Savings goal: $500/month                                      │
│                                                                  │
│  OUTPUT:                                                         │
│  • Optimized budget per category                                 │
│  • Feasible: Income - Fixed - Goals = Discretionary             │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Optimization Algorithm

```python
from scipy.optimize import minimize
import numpy as np

class BudgetOptimizer:
    """
    Optimizes budget using utility theory.
    """
    
    CATEGORY_UTILITY_PARAMS = {
        'food': {'a': 0.8, 'b': 0.02},
        'entertainment': {'a': 0.5, 'b': 0.05},
        'shopping': {'a': 0.4, 'b': 0.08},
        'transportation': {'a': 0.9, 'b': 0.01},
        'healthcare': {'a': 1.0, 'b': 0.005},
        'education': {'a': 0.7, 'b': 0.02},
    }
    
    CATEGORY_WEIGHTS = {
        'housing': 10, 'utilities': 10, 'food': 9,
        'healthcare': 9, 'transportation': 8, 'insurance': 8,
        'education': 7, 'savings': 7, 'entertainment': 4,
        'shopping': 3, 'personal': 4, 'other': 2
    }
    
    def optimize(
        self,
        monthly_income: float,
        fixed_expenses: float,
        savings_goal: float,
        current_spending: Dict[str, float]
    ) -> BudgetRecommendation:
        """
        Optimize budget allocation using utility maximization.
        """
        
        # Available for discretionary spending
        discretionary = monthly_income - fixed_expenses - savings_goal
        
        if discretionary <= 0:
            return BudgetRecommendation(
                success=False,
                message="Income doesn't cover fixed + savings goal"
            )
        
        # Optimize using scipy
        result = minimize(
            self._negative_utility,
            x0=self._initial_guess(discretionary),
            method='SLSQP',
            bounds=self._get_bounds(discretionary),
            constraints=[{'type': 'eq', 'fun': self._budget_constraint, 'args': (discretionary,)}]
        )
        
        return BudgetRecommendation(
            success=result.success,
            allocation=self._format_allocation(result.x, fixed_expenses, savings_goal)
        )
    
    def _utility_function(self, amount: float, category: str, current: float) -> float:
        """Logarithmic utility with diminishing returns."""
        
        params = self.CATEGORY_UTILITY_PARAMS.get(category, {'a': 0.5, 'b': 0.05})
        utility = params['a'] * np.log(1 + params['b'] * amount)
        
        # Disruption penalty
        disruption_penalty = 0.1 * abs(amount - current) / (current + 1)
        
        return utility - disruption_penalty
```

---

## 5. Complete API Integration

### 5.1 Supabase Edge Function

```typescript
// supabase/functions/finance-forecast/index.ts

Deno.serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? ''
  )

  // Get user
  const authHeader = req.headers.get('Authorization')!
  const token = authHeader.replace('Bearer ', '')
  const { data: { user } } = await supabaseClient.auth.getUser(token)

  if (!user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
  }

  const { prediction_days = 30, categories = null } = await req.json()

  // Fetch transactions
  const { data: transactions } = await supabaseClient
    .from('finance_entries')
    .select('*')
    .eq('user_id', user.id)
    .gte('date', new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString())

  // Call ML service
  const forecast = await fetch(`${Deno.env.get('ML_SERVICE_URL')}/predict/spending`, {
    method: 'POST',
    body: JSON.stringify({ transactions, prediction_days, categories })
  })

  const result = await forecast.json()
  return new Response(JSON.stringify(result))
})
```

---

## 6. Example Predictions

### 6.1 Spending Forecast Output

```json
{
  "food": {
    "predicted_amount": 485.50,
    "confidence": 0.82,
    "prediction_interval": {
      "lower": 350.00,
      "upper": 620.00
    },
    "model_version": "1.0.0",
    "factors": [
      {"name": "historical_avg", "impact": "+12%"},
      {"name": "payday_approaching", "impact": "+8%"},
      {"name": "seasonal_factor", "impact": "-3%"}
    ]
  },
  "transportation": {
    "predicted_amount": 150.00,
    "confidence": 0.88,
    "prediction_interval": {"lower": 120, "upper": 180}
  },
  "entertainment": {
    "predicted_amount": 95.00,
    "confidence": 0.75,
    "prediction_interval": {"lower": 50, "upper": 140}
  }
}
```

### 6.2 Anomaly Detection Output

```json
{
  "is_anomaly": true,
  "confidence": 0.89,
  "anomalies": [
    {
      "type": "amount",
      "method": "statistical",
      "confidence": 0.85,
      "reasons": ["Z-score 4.2 > 3", "3.5x typical food spending"]
    },
    {
      "type": "merchant",
      "method": "ml",
      "confidence": 0.75,
      "reasons": ["First-time merchant with high amount"]
    }
  ],
  "recommendation": "Review this transaction - significantly higher than normal"
}
```

---

## 7. Monitoring Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Forecast MAPE | Mean Absolute Percentage Error | < 25% |
| Anomaly Precision | % flagged that are real | > 60% |
| Anomaly Recall | % real anomalies flagged | > 80% |
| API Latency | Response time | < 500ms |
| Data Freshness | Age of data for predictions | < 1 hour |

---

## 8. Summary

| Component | Algorithm | Purpose |
|-----------|-----------|---------|
| **Spending Forecast** | Gradient Boosting Ensemble | Predict 30-day spending by category |
| **Anomaly Detection** | Multi-layer (Statistical + ML + Rules + Peer) | Flag unusual transactions |
| **Budget Optimization** | Utility Theory + SciPy | Optimize allocation for utility |

All models are:
- ✅ Trained on user-specific data
- ✅ Integrated via Supabase Edge Functions
- ✅ Backtested with historical data
- ✅ Monitored for accuracy
