class PredictionRequest {
  final double orbitalPeriod;
  final double transitDuration;
  final double transitDepth;
  final double planetaryRadius;
  final double equilibriumTemperature;
  final double insolationFlux;
  final double transitSignalToNoise;
  final double stellarEffectiveTemperature;
  final double stellarRadius;
  final double? impactParameter;
  final double? dispositionScore;
  final double? stellarSurfaceGravity;
  final String sessionId;

  PredictionRequest({
    required this.orbitalPeriod,
    required this.transitDuration,
    required this.transitDepth,
    required this.planetaryRadius,
    required this.equilibriumTemperature,
    required this.insolationFlux,
    required this.transitSignalToNoise,
    required this.stellarEffectiveTemperature,
    required this.stellarRadius,
    this.impactParameter,
    this.dispositionScore,
    this.stellarSurfaceGravity,
    this.sessionId = 'anonymous',
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'orbital_period': orbitalPeriod,
      'transit_duration': transitDuration,
      'transit_depth': transitDepth,
      'planetary_radius': planetaryRadius,
      'equilibrium_temperature': equilibriumTemperature,
      'insolation_flux': insolationFlux,
      'transit_signal_to_noise': transitSignalToNoise,
      'stellar_effective_temperature': stellarEffectiveTemperature,
      'stellar_radius': stellarRadius,
      'session_id': sessionId,
    };

    if (impactParameter != null) {
      data['impact_parameter'] = impactParameter;
    }
    if (dispositionScore != null) {
      data['disposition_score'] = dispositionScore;
    }
    if (stellarSurfaceGravity != null) {
      data['stellar_surface_gravity'] = stellarSurfaceGravity;
    }

    return data;
  }
}

class PredictionResult {
  final String prediction;
  final Map<String, double> confidenceScores;
  final double maxConfidence;
  final List<String>? featuresUsed;

  PredictionResult({
    required this.prediction,
    required this.confidenceScores,
    required this.maxConfidence,
    this.featuresUsed,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      prediction: json['prediction'] as String,
      confidenceScores: Map<String, double>.from(
        json['confidence_scores'].map((key, value) => MapEntry(key, value.toDouble())),
      ),
      maxConfidence: (json['max_confidence'] as num).toDouble(),
      featuresUsed: json['features_used'] != null 
          ? List<String>.from(json['features_used'])
          : null,
    );
  }

  String get confidenceLevel {
    final confidence = maxConfidence * 100;
    if (confidence >= 90) return 'Very High';
    if (confidence >= 80) return 'High';
    if (confidence >= 70) return 'Moderate';
    if (confidence >= 60) return 'Low';
    return 'Very Low';
  }

  String get interpretation {
    final confidence = (maxConfidence * 100).round();
    
    if (prediction == 'CONFIRMED') {
      return 'This celestial body is classified as a CONFIRMED exoplanet with $confidence% confidence. The analysis indicates strong evidence supporting its planetary nature.';
    } else if (prediction == 'CANDIDATE') {
      return 'This object is classified as an exoplanet CANDIDATE with $confidence% confidence. While showing promising planetary characteristics, additional observations may be needed.';
    } else {
      return 'This object is classified as a FALSE POSITIVE with $confidence% confidence. The analysis suggests the signals are likely caused by other astrophysical phenomena.';
    }
  }
}

class HistoryItem {
  final int id;
  final String timestamp;
  final Map<String, dynamic> inputFeatures;
  final String prediction;
  final Map<String, double> confidenceScores;
  final double maxConfidence;

  HistoryItem({
    required this.id,
    required this.timestamp,
    required this.inputFeatures,
    required this.prediction,
    required this.confidenceScores,
    required this.maxConfidence,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as int,
      timestamp: json['timestamp'] as String,
      inputFeatures: Map<String, dynamic>.from(json['input_features']),
      prediction: json['prediction'] as String,
      confidenceScores: Map<String, double>.from(
        json['confidence_scores'].map((key, value) => MapEntry(key, value.toDouble())),
      ),
      maxConfidence: (json['max_confidence'] as num).toDouble(),
    );
  }

  DateTime get dateTime => DateTime.parse(timestamp);
  
  String get formattedTimestamp {
    final date = dateTime;
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class UploadResult {
  final bool success;
  final String filename;
  final String message;
  final dynamic dataPreview;

  UploadResult({
    required this.success,
    required this.filename,
    required this.message,
    this.dataPreview,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      success: json['success'] as bool,
      filename: json['filename'] as String,
      message: json['message'] as String,
      dataPreview: json['data_preview'],
    );
  }
}

class ModelInfo {
  final String modelType;
  final List<String> features;
  final List<String> classes;
  final bool modelLoaded;
  final int featureCount;

  ModelInfo({
    required this.modelType,
    required this.features,
    required this.classes,
    required this.modelLoaded,
    required this.featureCount,
  });

  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      modelType: json['model_type'] as String,
      features: List<String>.from(json['features']),
      classes: List<String>.from(json['classes']),
      modelLoaded: json['model_loaded'] as bool,
      featureCount: json['feature_count'] as int,
    );
  }
}
