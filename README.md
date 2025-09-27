# KeplerAI - Exoplanet Classification App

🚀 **Discover the cosmos with AI-powered exoplanet detection**

KeplerAI is a cutting-edge application that analyzes astronomical datasets to determine whether celestial bodies are confirmed exoplanets, candidates, or false positives. Using advanced machine learning algorithms trained on Kepler mission data, it provides accurate predictions with confidence scores.

## Features

- 🌌 **Dark Space Theme** - Immersive UI with glowing neon accents
- 🤖 **AI-Powered Analysis** - Random Forest model trained on KOI dataset
- 📱 **Cross-Platform** - Flutter mobile app and React web interface
- 📊 **Detailed Results** - Confidence scores and visualization charts
- 📈 **Prediction History** - Track and search past analyses
- 📁 **Multiple File Formats** - Support for CSV, FITS, and JSON uploads

## Technical Stack

- **Backend**: Python Flask with ML inference engine
- **Frontend**: Flutter (mobile) + React (web)
- **ML**: scikit-learn Random Forest classifier
- **Database**: SQLite with optional MongoDB support
- **Deployment**: Docker-ready with deployment scripts

## Quick Start

1. **Install Dependencies**:
   ```bash
   pip install -r backend/requirements.txt
   npm install
   ```

2. **Train ML Model**:
   ```bash
   cd backend
   python train_model.py
   ```

3. **Start Backend**:
   ```bash
   python app.py
   ```

4. **Launch Frontend**:
   ```bash
   # For React web app
   cd frontend/web
   npm start
   
   # For Flutter mobile app
   cd frontend/mobile
   flutter run
   ```

## Input Parameters

### Required Parameters
- Orbital Period
- Transit Duration
- Transit Depth
- Planetary Radius
- Equilibrium Temperature
- Insolation Flux
- Transit Signal to Noise
- Stellar Effective Temperature
- Stellar Radius

### Optional Parameters
- Impact Parameter
- Disposition Score
- Stellar Surface Gravity

## App Store Description

**KeplerAI - Exoplanet Discovery**

Unlock the mysteries of the universe with KeplerAI, the premier exoplanet classification app. Whether you're an astronomer, researcher, or space enthusiast, KeplerAI transforms complex astronomical data into clear, actionable insights.

**Key Features:**
✨ AI-powered exoplanet classification
🌌 Beautiful space-themed interface
📊 Detailed confidence scoring
📱 Cross-platform compatibility
🔬 Scientific accuracy you can trust

**Perfect for:**
- Astronomical research
- Educational purposes
- Space exploration enthusiasts
- Data scientists in astronomy

Download KeplerAI today and join the next generation of space discovery!

## License

MIT License - See LICENSE file for details

## Contributing

We welcome contributions! Please see CONTRIBUTING.md for guidelines.

---

*"Exploring the cosmos, one exoplanet at a time"* 🌟
