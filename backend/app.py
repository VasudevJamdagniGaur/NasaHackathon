#!/usr/bin/env python3
"""
KeplerAI Backend API
Flask server for exoplanet classification with ML inference.
"""

from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import pandas as pd
import numpy as np
import joblib
import os
import sqlite3
from datetime import datetime
import json
import logging
from werkzeug.utils import secure_filename
import traceback

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'csv', 'json', 'fits'}
MODEL_DIR = 'models'
DATABASE = 'kepler_ai.db'

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Ensure directories exist
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(MODEL_DIR, exist_ok=True)

class ExoplanetPredictor:
    def __init__(self):
        self.model = None
        self.scaler = None
        self.label_encoder = None
        self.feature_columns = None
        self.load_model()
    
    def load_model(self):
        """Load the trained model and preprocessing objects"""
        try:
            model_path = os.path.join(MODEL_DIR, 'exoplanet_classifier.pkl')
            scaler_path = os.path.join(MODEL_DIR, 'feature_scaler.pkl')
            encoder_path = os.path.join(MODEL_DIR, 'label_encoder.pkl')
            features_path = os.path.join(MODEL_DIR, 'feature_names.txt')
            
            if all(os.path.exists(path) for path in [model_path, scaler_path, encoder_path, features_path]):
                self.model = joblib.load(model_path)
                self.scaler = joblib.load(scaler_path)
                self.label_encoder = joblib.load(encoder_path)
                
                # Load feature names
                with open(features_path, 'r') as f:
                    self.feature_columns = [line.strip() for line in f.readlines()]
                
                logger.info("Model loaded successfully!")
            else:
                logger.warning("Model files not found. Please train the model first.")
                
        except Exception as e:
            logger.error(f"Error loading model: {str(e)}")
    
    def predict(self, features):
        """Make prediction on input features"""
        if self.model is None:
            raise ValueError("Model not loaded. Please train the model first.")
        
        try:
            # Convert to DataFrame if dict
            if isinstance(features, dict):
                features_df = pd.DataFrame([features])
            else:
                features_df = features.copy()
            
            # Ensure all required columns are present
            for col in self.feature_columns:
                if col not in features_df.columns:
                    # Fill missing optional parameters with median values
                    if col in ['koi_impact', 'koi_score', 'koi_slogg']:
                        features_df[col] = 0.0  # Default value for optional params
                    else:
                        raise ValueError(f"Required feature '{col}' is missing")
            
            # Select only the required features in correct order
            features_selected = features_df[self.feature_columns]
            
            # Scale features
            features_scaled = self.scaler.transform(features_selected)
            
            # Make prediction
            prediction = self.model.predict(features_scaled)
            probabilities = self.model.predict_proba(features_scaled)
            
            # Convert back to original labels
            predicted_label = self.label_encoder.inverse_transform(prediction)[0]
            
            # Get confidence scores
            confidence_scores = {}
            for i, class_name in enumerate(self.label_encoder.classes_):
                confidence_scores[class_name] = float(probabilities[0][i])
            
            # Merge CONFIRMED and CANDIDATE categories
            merged_confidence_scores = {}
            confirmed_candidate_score = 0.0
            
            for class_name, score in confidence_scores.items():
                if class_name in ['CONFIRMED', 'CANDIDATE']:
                    confirmed_candidate_score += score
                else:
                    merged_confidence_scores[class_name] = score
            
            # Add merged category
            merged_confidence_scores['CONFIRMED/CANDIDATE'] = confirmed_candidate_score
            
            # Determine final prediction based on CONFIRMED/CANDIDATE vs FALSE POSITIVE comparison
            false_positive_score = merged_confidence_scores.get('FALSE POSITIVE', 0.0)
            
            if confirmed_candidate_score > false_positive_score:
                final_prediction = 'CONFIRMED/CANDIDATE'
                max_confidence = confirmed_candidate_score
            else:
                final_prediction = 'FALSE POSITIVE'
                max_confidence = false_positive_score
            
            confidence_scores = merged_confidence_scores
            
            return {
                'prediction': final_prediction,
                'confidence_scores': confidence_scores,
                'max_confidence': float(max_confidence),
                'features_used': self.feature_columns
            }
            
        except Exception as e:
            logger.error(f"Prediction error: {str(e)}")
            raise

# Initialize predictor
predictor = ExoplanetPredictor()

def init_database():
    """Initialize SQLite database for storing predictions"""
    conn = sqlite3.connect(DATABASE)
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS predictions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            input_features TEXT,
            prediction TEXT,
            confidence_scores TEXT,
            max_confidence REAL,
            user_session TEXT
        )
    ''')
    
    conn.commit()
    conn.close()

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/')
def home():
    """Health check endpoint"""
    return jsonify({
        'message': 'KeplerAI Backend API',
        'version': '1.0.0',
        'status': 'running',
        'model_loaded': predictor.model is not None
    })

@app.route('/api/predict', methods=['POST'])
def predict_exoplanet():
    """Predict exoplanet classification from input features"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No input data provided'}), 400
        
        # Extract features
        features = {}
        required_features = [
            'orbital_period', 'transit_duration', 'transit_depth',
            'planetary_radius', 'equilibrium_temperature', 'insolation_flux',
            'transit_signal_to_noise', 'stellar_effective_temperature', 'stellar_radius'
        ]
        
        optional_features = [
            'impact_parameter', 'disposition_score', 'stellar_surface_gravity'
        ]
        
        # Map frontend names to model feature names
        feature_mapping = {
            'orbital_period': 'koi_period',
            'transit_duration': 'koi_duration',
            'transit_depth': 'koi_depth',
            'planetary_radius': 'koi_prad',
            'equilibrium_temperature': 'koi_teq',
            'insolation_flux': 'koi_insol',
            'transit_signal_to_noise': 'koi_model_snr',
            'stellar_effective_temperature': 'koi_steff',
            'stellar_radius': 'koi_srad',
            'impact_parameter': 'koi_impact',
            'disposition_score': 'koi_score',
            'stellar_surface_gravity': 'koi_slogg'
        }
        
        # Check required features
        for feature in required_features:
            if feature not in data:
                return jsonify({'error': f'Required feature "{feature}" is missing'}), 400
            features[feature_mapping[feature]] = float(data[feature])
        
        # Add optional features
        for feature in optional_features:
            if feature in data and data[feature] is not None:
                features[feature_mapping[feature]] = float(data[feature])
        
        # Make prediction
        result = predictor.predict(features)
        
        # Store prediction in database
        user_session = data.get('session_id', 'anonymous')
        store_prediction(features, result, user_session)
        
        return jsonify({
            'success': True,
            'result': result,
            'timestamp': datetime.now().isoformat()
        })
        
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        logger.error(f"Prediction error: {str(e)}")
        logger.error(traceback.format_exc())
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/api/upload', methods=['POST'])
def upload_file():
    """Upload and process data files"""
    try:
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(filepath)
            
            # Process file based on type
            file_ext = filename.rsplit('.', 1)[1].lower()
            
            if file_ext == 'csv':
                df = pd.read_csv(filepath)
                data = df.to_dict('records')
            elif file_ext == 'json':
                with open(filepath, 'r') as f:
                    data = json.load(f)
            elif file_ext == 'fits':
                # Basic FITS file handling (requires astropy)
                try:
                    from astropy.io import fits
                    with fits.open(filepath) as hdul:
                        data = {'message': 'FITS file uploaded successfully', 'headers': len(hdul)}
                except ImportError:
                    data = {'message': 'FITS file uploaded, but astropy not available for processing'}
            
            return jsonify({
                'success': True,
                'filename': filename,
                'data_preview': data[:5] if isinstance(data, list) else data,
                'message': f'File uploaded successfully'
            })
        
        return jsonify({'error': 'File type not allowed'}), 400
        
    except Exception as e:
        logger.error(f"Upload error: {str(e)}")
        return jsonify({'error': 'File upload failed'}), 500

@app.route('/api/history', methods=['GET'])
def get_prediction_history():
    """Get prediction history"""
    try:
        session_id = request.args.get('session_id', 'anonymous')
        limit = int(request.args.get('limit', 50))
        
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        
        cursor.execute('''
            SELECT id, timestamp, input_features, prediction, confidence_scores, max_confidence
            FROM predictions 
            WHERE user_session = ?
            ORDER BY timestamp DESC
            LIMIT ?
        ''', (session_id, limit))
        
        rows = cursor.fetchall()
        conn.close()
        
        history = []
        for row in rows:
            history.append({
                'id': row[0],
                'timestamp': row[1],
                'input_features': json.loads(row[2]),
                'prediction': row[3],
                'confidence_scores': json.loads(row[4]),
                'max_confidence': row[5]
            })
        
        return jsonify({
            'success': True,
            'history': history,
            'count': len(history)
        })
        
    except Exception as e:
        logger.error(f"History error: {str(e)}")
        return jsonify({'error': 'Failed to retrieve history'}), 500

@app.route('/api/model/info', methods=['GET'])
def get_model_info():
    """Get model information and statistics"""
    try:
        if predictor.model is None:
            return jsonify({'error': 'Model not loaded'}), 500
        
        info = {
            'model_type': 'Random Forest Classifier',
            'features': predictor.feature_columns,
            'classes': predictor.label_encoder.classes_.tolist() if predictor.label_encoder else [],
            'model_loaded': True,
            'feature_count': len(predictor.feature_columns) if predictor.feature_columns else 0
        }
        
        return jsonify({
            'success': True,
            'model_info': info
        })
        
    except Exception as e:
        logger.error(f"Model info error: {str(e)}")
        return jsonify({'error': 'Failed to get model info'}), 500

def store_prediction(features, result, user_session):
    """Store prediction in database"""
    try:
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO predictions (input_features, prediction, confidence_scores, max_confidence, user_session)
            VALUES (?, ?, ?, ?, ?)
        ''', (
            json.dumps(features),
            result['prediction'],
            json.dumps(result['confidence_scores']),
            result['max_confidence'],
            user_session
        ))
        
        conn.commit()
        conn.close()
        
    except Exception as e:
        logger.error(f"Database error: {str(e)}")

@app.errorhandler(413)
def too_large(e):
    return jsonify({'error': 'File too large. Maximum size is 16MB.'}), 413

@app.errorhandler(404)
def not_found(e):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(e):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # Initialize database
    init_database()
    
    # Start server
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    
    print("🚀 KeplerAI Backend API Starting...")
    print(f"Server running on http://localhost:{port}")
    print(f"Model loaded: {predictor.model is not None}")
    
    app.run(host='0.0.0.0', port=port, debug=debug)
