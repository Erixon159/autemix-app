#!/bin/bash

# Dependency management script for Autemix Admin Platform
# Usage: ./scripts/deps.sh [install|update|check]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to install backend dependencies
install_backend() {
    echo -e "${BLUE}Installing backend dependencies...${NC}"
    docker compose run --rm backend-dev bundle install --quiet
    echo -e "${GREEN}Backend dependencies installed!${NC}"
}

# Function to install frontend dependencies
install_frontend() {
    echo -e "${BLUE}Installing frontend dependencies...${NC}"
    docker compose run --rm frontend-dev npm ci --silent
    echo -e "${GREEN}Frontend dependencies installed!${NC}"
}

# Function to update dependencies
update_backend() {
    echo -e "${BLUE}Updating backend dependencies...${NC}"
    docker compose run --rm backend-dev bundle update --quiet
    echo -e "${GREEN}Backend dependencies updated!${NC}"
}

update_frontend() {
    echo -e "${BLUE}Updating frontend dependencies...${NC}"
    docker compose run --rm frontend-dev npm update --silent
    echo -e "${GREEN}Frontend dependencies updated!${NC}"
}

# Function to check dependency status
check_deps() {
    echo -e "${BLUE}Checking dependency status...${NC}"
    
    echo -e "${YELLOW}Backend gems:${NC}"
    docker compose run --rm backend-dev bundle check || echo "Backend dependencies need installation"
    
    echo -e "${YELLOW}Frontend packages:${NC}"
    docker compose run --rm frontend-dev npm ls --depth=0 --silent || echo "Frontend dependencies need installation"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [install|update|check|backend|frontend]"
    echo "  install   - Install all dependencies"
    echo "  update    - Update all dependencies"
    echo "  check     - Check dependency status"
    echo "  backend   - Install only backend dependencies"
    echo "  frontend  - Install only frontend dependencies"
}

# Main script logic
case "${1:-install}" in
    install)
        install_backend
        install_frontend
        ;;
    update)
        update_backend
        update_frontend
        ;;
    check)
        check_deps
        ;;
    backend)
        install_backend
        ;;
    frontend)
        install_frontend
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        echo -e "${RED}Invalid option: $1${NC}"
        show_usage
        exit 1
        ;;
esac

echo -e "${GREEN}Dependencies management completed!${NC}"
