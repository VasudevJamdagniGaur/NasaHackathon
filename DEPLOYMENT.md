# KeplerAI Deployment Guide

## Quick Start

### Option 1: Automatic Setup (Recommended)

**Windows:**
```bash
deploy.bat setup
deploy.bat dev
```

**Linux/Mac:**
```bash
chmod +x deploy.sh
./deploy.sh setup
./deploy.sh dev
```

### Option 2: Docker Deployment
```bash
# Windows
deploy.bat docker

# Linux/Mac
./deploy.sh docker
```

## Manual Setup

### Prerequisites
- Python 3.8+
- Node.js 16+ (for web development)
- Flutter SDK (for mobile development)
- Docker & Docker Compose (for containerized deployment)

### Step 1: Clone and Setup Backend
```bash
cd backend
pip install -r requirements.txt
python train_model.py  # Train the ML model
python app.py          # Start backend server
```

### Step 2: Setup React Web App
```bash
cd frontend/web
npm install
npm start              # Development server
# OR
npm run build         # Production build
```

### Step 3: Setup Flutter Mobile App
```bash
cd frontend/mobile
flutter pub get
flutter run           # Development
# OR
flutter build apk     # Android build
flutter build ios     # iOS build
```

## Production Deployment

### Docker Compose (Recommended)
```bash
docker-compose up --build -d
```

This starts:
- Backend API on port 5000
- React web app on port 3000
- Nginx reverse proxy on port 80 (optional)

### Individual Services

#### Backend API
```bash
cd backend
gunicorn --bind 0.0.0.0:5000 --workers 4 app:app
```

#### React Web App
```bash
cd frontend/web
npm run build
# Serve build folder with nginx, apache, or static server
```

#### Flutter Mobile App
```bash
cd frontend/mobile
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Environment Configuration

### Backend Environment Variables
```bash
export FLASK_ENV=production
export PORT=5000
export DATABASE_URL=sqlite:///kepler_ai.db
```

### Frontend Environment Variables
```bash
# React (.env file)
REACT_APP_API_URL=http://localhost:5000/api

# Flutter (lib/config.dart)
const String API_BASE_URL = 'http://localhost:5000/api';
```

## Database Setup

The application uses SQLite by default. For production, consider PostgreSQL:

```bash
# Install PostgreSQL dependencies
pip install psycopg2-binary

# Update backend/app.py database connection
# Replace SQLite with PostgreSQL connection string
```

## SSL/HTTPS Setup

### Using Let's Encrypt with Nginx
```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### SSL Configuration
Update `nginx.conf` for HTTPS:
```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    # ... rest of configuration
}
```

## Cloud Deployment

### AWS Deployment
1. **EC2 Instance**: Deploy using Docker on EC2
2. **ECS**: Use provided Docker images with ECS
3. **Lambda**: Backend API can be adapted for serverless
4. **S3 + CloudFront**: Static React app hosting

### Google Cloud Platform
1. **Cloud Run**: Deploy containerized services
2. **App Engine**: Python backend deployment
3. **Firebase Hosting**: React app hosting
4. **Cloud Storage**: File upload storage

### Azure Deployment
1. **Container Instances**: Docker deployment
2. **App Service**: Web app hosting
3. **Static Web Apps**: React frontend
4. **Blob Storage**: File storage

## Monitoring and Logging

### Application Monitoring
```python
# Add to backend/app.py
import logging
logging.basicConfig(level=logging.INFO)

# Health check endpoint already included
```

### Docker Logging
```bash
# View logs
docker-compose logs -f kepler-api
docker-compose logs -f kepler-web

# Log rotation
docker-compose logs --tail=100 -f
```

### Performance Monitoring
- Use APM tools like New Relic, DataDog, or Sentry
- Monitor API response times and error rates
- Track ML model prediction performance

## Security Considerations

### API Security
- Enable CORS properly for production domains
- Implement rate limiting
- Add API authentication if needed
- Validate all input parameters

### Database Security
- Use environment variables for database credentials
- Enable database encryption at rest
- Regular backups and security updates

### Network Security
- Use HTTPS in production
- Implement proper firewall rules
- Regular security updates for all dependencies

## Scaling

### Horizontal Scaling
```yaml
# docker-compose.yml
services:
  kepler-api:
    deploy:
      replicas: 3
    # Add load balancer
```

### Database Scaling
- Read replicas for better performance
- Connection pooling
- Database optimization for ML model queries

### CDN Integration
- Use CloudFlare, AWS CloudFront, or similar
- Cache static assets and API responses where appropriate

## Backup Strategy

### Database Backups
```bash
# SQLite backup
cp backend/kepler_ai.db backup/kepler_ai_$(date +%Y%m%d).db

# Automated backup script
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
cp backend/kepler_ai.db $BACKUP_DIR/kepler_ai_$DATE.db
find $BACKUP_DIR -name "kepler_ai_*.db" -mtime +7 -delete
```

### Model and Data Backups
```bash
# Backup trained models
tar -czf models_backup_$(date +%Y%m%d).tar.gz backend/models/

# Backup uploaded files
tar -czf uploads_backup_$(date +%Y%m%d).tar.gz backend/uploads/
```

## Troubleshooting

### Common Issues

1. **Model not found error**
   ```bash
   cd backend
   python train_model.py
   ```

2. **CORS errors**
   - Check FLASK_CORS configuration in backend
   - Verify frontend API URL configuration

3. **Database connection issues**
   - Check file permissions for SQLite
   - Verify database path in app.py

4. **Docker build failures**
   - Check Docker daemon is running
   - Verify all required files are present
   - Check system resources (disk space, memory)

### Performance Issues

1. **Slow predictions**
   - Check model file integrity
   - Monitor CPU/memory usage
   - Consider model optimization

2. **High memory usage**
   - Implement connection pooling
   - Add memory limits to Docker containers
   - Monitor for memory leaks

### Log Analysis
```bash
# Backend logs
tail -f backend/app.log

# Docker logs
docker-compose logs --follow

# System logs
journalctl -f -u docker
```

## Support and Maintenance

### Regular Maintenance Tasks
- Update dependencies monthly
- Monitor disk usage and clean old logs
- Review and rotate API keys/secrets
- Test backup and restore procedures

### Version Updates
1. Test in staging environment
2. Backup current version
3. Deploy new version
4. Verify functionality
5. Monitor for issues

### Getting Help
- Check GitHub Issues for common problems
- Review application logs for error details
- Contact development team for critical issues

---

## Quick Reference

### Useful Commands
```bash
# Check application status
curl http://localhost:5000/
curl http://localhost:3000/

# View Docker status
docker-compose ps
docker-compose top

# Database operations
sqlite3 backend/kepler_ai.db ".tables"
sqlite3 backend/kepler_ai.db "SELECT COUNT(*) FROM predictions;"

# Log monitoring
tail -f backend/app.log | grep ERROR
docker-compose logs -f --tail=100
```

### Default Ports
- Backend API: 5000
- React Web: 3000
- Nginx Proxy: 80/443
- Flutter Mobile: Connects to backend API

### File Locations
- ML Model: `backend/models/exoplanet_classifier.pkl`
- Database: `backend/kepler_ai.db`
- Uploads: `backend/uploads/`
- Logs: `backend/app.log`
