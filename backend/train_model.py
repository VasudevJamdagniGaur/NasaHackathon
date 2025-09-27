#!/usr/bin/env python3
"""
KeplerAI - Exoplanet Classification Model Training
Trains a Random Forest classifier on the KOI dataset to predict exoplanet disposition.
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split, GridSearchCV, cross_val_score
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score
import joblib
import matplotlib.pyplot as plt
import seaborn as sns
import os
import warnings
warnings.filterwarnings('ignore')

class ExoplanetClassifier:
    def __init__(self):
        self.model = None
        self.scaler = StandardScaler()
        self.label_encoder = LabelEncoder()
        self.feature_columns = [
            'koi_period',        # Orbital Period
            'koi_duration',      # Transit Duration  
            'koi_depth',         # Transit Depth
            'koi_prad',          # Planetary Radius
            'koi_teq',           # Equilibrium Temperature
            'koi_insol',         # Insolation Flux
            'koi_model_snr',     # Transit Signal to Noise
            'koi_steff',         # Stellar Effective Temperature
            'koi_srad',          # Stellar Radius
            # Optional parameters
            'koi_impact',        # Impact Parameter
            'koi_score',         # Disposition Score
            'koi_slogg'          # Stellar Surface Gravity
        ]
        self.target_column = 'koi_disposition'
        
    def load_and_preprocess_data(self, csv_path):
        """Load and preprocess the KOI dataset"""
        print("Loading KOI dataset...")
        
        # Read CSV, skipping comment lines
        df = pd.read_csv(csv_path, comment='#')
        print(f"Loaded {len(df)} records")
        
        # Filter for relevant dispositions
        valid_dispositions = ['CONFIRMED', 'CANDIDATE', 'FALSE POSITIVE']
        df = df[df[self.target_column].isin(valid_dispositions)]
        print(f"After filtering dispositions: {len(df)} records")
        
        # Select required columns
        columns_to_use = self.feature_columns + [self.target_column]
        df = df[columns_to_use]
        
        # Handle missing values
        print("Handling missing values...")
        # For required parameters, drop rows with missing values
        required_cols = self.feature_columns[:9]  # First 9 are required
        df = df.dropna(subset=required_cols)
        
        # For optional parameters, fill with median values
        optional_cols = self.feature_columns[9:]  # Last 3 are optional
        for col in optional_cols:
            if col in df.columns:
                df[col] = df[col].fillna(df[col].median())
        
        print(f"After handling missing values: {len(df)} records")
        
        # Remove outliers using IQR method
        print("Removing outliers...")
        for col in self.feature_columns:
            if col in df.columns:
                Q1 = df[col].quantile(0.25)
                Q3 = df[col].quantile(0.75)
                IQR = Q3 - Q1
                lower_bound = Q1 - 1.5 * IQR
                upper_bound = Q3 + 1.5 * IQR
                df = df[(df[col] >= lower_bound) & (df[col] <= upper_bound)]
        
        print(f"After outlier removal: {len(df)} records")
        
        # Display class distribution
        print("\nClass distribution:")
        print(df[self.target_column].value_counts())
        
        return df
    
    def train_model(self, df):
        """Train the Random Forest classifier"""
        print("\nPreparing features and targets...")
        
        # Prepare features and target
        X = df[self.feature_columns].copy()
        y = df[self.target_column].copy()
        
        # Encode target labels
        y_encoded = self.label_encoder.fit_transform(y)
        
        # Split the data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y_encoded, test_size=0.2, random_state=42, stratify=y_encoded
        )
        
        # Scale features
        X_train_scaled = self.scaler.fit_transform(X_train)
        X_test_scaled = self.scaler.transform(X_test)
        
        print("Training Random Forest classifier...")
        
        # Use optimized Random Forest parameters (pre-tuned for speed)
        self.model = RandomForestClassifier(
            n_estimators=100,
            max_depth=10,
            min_samples_split=5,
            min_samples_leaf=1,
            max_features='sqrt',
            random_state=42,
            n_jobs=1  # Use single thread to avoid multiprocessing issues
        )
        
        self.model.fit(X_train_scaled, y_train)
        print("Model training completed!")
        
        # Evaluate model
        y_pred = self.model.predict(X_test_scaled)
        accuracy = accuracy_score(y_test, y_pred)
        print(f"\nModel Accuracy: {accuracy:.4f}")
        
        # Cross-validation score
        cv_scores = cross_val_score(self.model, X_train_scaled, y_train, cv=5)
        print(f"Cross-validation score: {cv_scores.mean():.4f} (+/- {cv_scores.std() * 2:.4f})")
        
        # Classification report
        print("\nClassification Report:")
        target_names = self.label_encoder.classes_
        print(classification_report(y_test, y_pred, target_names=target_names))
        
        # Feature importance
        self.plot_feature_importance()
        
        # Confusion matrix
        self.plot_confusion_matrix(y_test, y_pred, target_names)
        
        return accuracy
    
    def plot_feature_importance(self):
        """Plot feature importance"""
        if self.model is None:
            return
        
        importance = self.model.feature_importances_
        feature_names = [name.replace('koi_', '') for name in self.feature_columns]
        
        plt.figure(figsize=(10, 8))
        indices = np.argsort(importance)[::-1]
        
        plt.title('Feature Importance - Exoplanet Classification')
        plt.bar(range(len(importance)), importance[indices])
        plt.xticks(range(len(importance)), [feature_names[i] for i in indices], rotation=45)
        plt.tight_layout()
        plt.savefig('models/feature_importance.png', dpi=300, bbox_inches='tight')
        plt.close()
        
    def plot_confusion_matrix(self, y_true, y_pred, target_names):
        """Plot confusion matrix"""
        cm = confusion_matrix(y_true, y_pred)
        
        plt.figure(figsize=(8, 6))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                   xticklabels=target_names, yticklabels=target_names)
        plt.title('Confusion Matrix - Exoplanet Classification')
        plt.ylabel('True Label')
        plt.xlabel('Predicted Label')
        plt.tight_layout()
        plt.savefig('models/confusion_matrix.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    def save_model(self, model_dir='models'):
        """Save the trained model and preprocessing objects"""
        os.makedirs(model_dir, exist_ok=True)
        
        joblib.dump(self.model, os.path.join(model_dir, 'exoplanet_classifier.pkl'))
        joblib.dump(self.scaler, os.path.join(model_dir, 'feature_scaler.pkl'))
        joblib.dump(self.label_encoder, os.path.join(model_dir, 'label_encoder.pkl'))
        
        # Save feature names
        with open(os.path.join(model_dir, 'feature_names.txt'), 'w') as f:
            for feature in self.feature_columns:
                f.write(f"{feature}\n")
        
        print(f"Model saved to {model_dir}")
    
    def predict(self, features):
        """Make predictions on new data"""
        if self.model is None:
            raise ValueError("Model not trained yet!")
        
        # Ensure features is a DataFrame with correct columns
        if isinstance(features, dict):
            features = pd.DataFrame([features])
        
        # Scale features
        features_scaled = self.scaler.transform(features[self.feature_columns])
        
        # Make prediction
        prediction = self.model.predict(features_scaled)
        probabilities = self.model.predict_proba(features_scaled)
        
        # Convert back to original labels
        predicted_label = self.label_encoder.inverse_transform(prediction)[0]
        
        # Get confidence scores for all classes
        confidence_scores = {}
        for i, class_name in enumerate(self.label_encoder.classes_):
            confidence_scores[class_name] = float(probabilities[0][i])
        
        return {
            'prediction': predicted_label,
            'confidence_scores': confidence_scores,
            'max_confidence': float(max(probabilities[0]))
        }

def main():
    """Main training function"""
    print("🚀 KeplerAI - Training Exoplanet Classification Model")
    print("=" * 60)
    
    # Initialize classifier
    classifier = ExoplanetClassifier()
    
    # Load and preprocess data
    df = classifier.load_and_preprocess_data('../KOI.csv')
    
    # Train model
    accuracy = classifier.train_model(df)
    
    # Save model
    classifier.save_model()
    
    print("=" * 60)
    print(f"🎉 Training completed! Model accuracy: {accuracy:.4f}")
    print("Model saved to backend/models/")
    print("Ready for deployment! 🌟")

if __name__ == "__main__":
    main()
