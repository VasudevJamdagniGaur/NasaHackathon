#!/bin/bash

# KeplerAI Deployment Script
# This script sets up and deploys the KeplerAI application

set -e

echo "🚀 KeplerAI Deployment Script"
echo "=============================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker and Docker Compose are installed"
}

# Check if Python is installed for ML model training
check_python() {
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed. Please install Python 3 first."
        exit 1
    fi
    print_success "Python 3 is installed"
}

# Install Python dependencies
install_python_deps() {
    print_status "Installing Python dependencies..."
    cd backend
    pip3 install -r requirements.txt
    cd ..
    print_success "Python dependencies installed"
}

# Train the ML model if not exists
train_model() {
    if [ ! -f "backend/models/exoplanet_classifier.pkl" ]; then
        print_status "Training ML model (this may take a few minutes)..."
        cd backend
        python3 train_model.py
        cd ..
        print_success "ML model trained successfully"
    else
        print_success "ML model already exists"
    fi
}

# Install Node.js dependencies for React app
install_node_deps() {
    if command -v npm &> /dev/null; then
        print_status "Installing Node.js dependencies..."
        cd frontend/web
        npm install
        cd ../..
        print_success "Node.js dependencies installed"
    else
        print_warning "Node.js/npm not found. Web app will be built in Docker."
    fi
}

# Build and start Docker containers
deploy_with_docker() {
    print_status "Building and starting Docker containers..."
    
    # Stop existing containers
    docker-compose down 2>/dev/null || true
    
    # Build and start containers
    docker-compose up --build -d
    
    print_success "Docker containers started successfully"
}

# Start development servers locally
start_dev_servers() {
    print_status "Starting development servers..."
    
    # Start backend in background
    cd backend
    python3 app.py &
    BACKEND_PID=$!
    cd ..
    
    # Start frontend in background
    if command -v npm &> /dev/null; then
        cd frontend/web
        npm start &
        FRONTEND_PID=$!
        cd ../..
    fi
    
    print_success "Development servers started"
    print_status "Backend running on http://localhost:5000"
    print_status "Frontend running on http://localhost:3000"
    
    # Save PIDs for cleanup
    echo $BACKEND_PID > .backend.pid
    if [ ! -z "$FRONTEND_PID" ]; then
        echo $FRONTEND_PID > .frontend.pid
    fi
}

# Stop development servers
stop_dev_servers() {
    print_status "Stopping development servers..."
    
    if [ -f ".backend.pid" ]; then
        kill $(cat .backend.pid) 2>/dev/null || true
        rm .backend.pid
    fi
    
    if [ -f ".frontend.pid" ]; then
        kill $(cat .frontend.pid) 2>/dev/null || true
        rm .frontend.pid
    fi
    
    print_success "Development servers stopped"
}

# Display usage information
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  setup     - Install dependencies and train ML model"
    echo "  dev       - Start development servers"
    echo "  stop      - Stop development servers"
    echo "  docker    - Deploy with Docker"
    echo "  clean     - Clean up Docker containers and images"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup     # First time setup"
    echo "  $0 dev       # Start development"
    echo "  $0 docker    # Production deployment"
}

# Clean up Docker resources
clean_docker() {
    print_status "Cleaning up Docker resources..."
    docker-compose down --rmi all --volumes --remove-orphans 2>/dev/null || true
    print_success "Docker cleanup completed"
}

# Main deployment logic
main() {
    case "${1:-setup}" in
        "setup")
            print_status "Setting up KeplerAI..."
            check_python
            install_python_deps
            train_model
            install_node_deps
            print_success "Setup completed! Run '$0 dev' to start development servers."
            ;;
        "dev")
            check_python
            start_dev_servers
            echo ""
            print_success "KeplerAI is running!"
            print_status "🌐 Web App: http://localhost:3000"
            print_status "🔧 API: http://localhost:5000"
            print_status "📱 Mobile: Connect Flutter app to http://localhost:5000"
            echo ""
            print_status "Press Ctrl+C to stop servers"
            wait
            ;;
        "stop")
            stop_dev_servers
            ;;
        "docker")
            check_docker
            check_python
            install_python_deps
            train_model
            deploy_with_docker
            echo ""
            print_success "KeplerAI deployed with Docker!"
            print_status "🌐 Web App: http://localhost:3000"
            print_status "🔧 API: http://localhost:5000"
            print_status "📊 Full App: http://localhost (if using nginx)"
            ;;
        "clean")
            clean_docker
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
