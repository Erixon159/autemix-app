#!/bin/bash

# Build script for Autemix Admin Platform Docker images with multi-architecture support
# Usage: ./scripts/build.sh [production|development|all] [--push]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get version from VERSION file
VERSION=$(cat VERSION)
echo -e "${BLUE}Building Autemix Admin Platform v${VERSION} (Multi-Architecture)${NC}"

# Default registry (can be overridden with REGISTRY env var)
REGISTRY=${REGISTRY:-"ghcr.io/autemix"}

# Target platforms for multi-architecture builds
PLATFORMS="linux/amd64,linux/arm64"

# Check if --push flag is provided
PUSH_FLAG=""
if [[ "$*" == *"--push"* ]]; then
    PUSH_FLAG="--push"
    echo -e "${YELLOW}Images will be pushed to registry after building${NC}"
fi

# Ensure buildx is available and create builder if needed
setup_buildx() {
    echo -e "${BLUE}Setting up Docker Buildx for multi-architecture builds...${NC}"
    
    # Create buildx builder if it doesn't exist
    if ! docker buildx ls | grep -q "autemix-builder"; then
        echo -e "${YELLOW}Creating multi-architecture builder...${NC}"
        docker buildx create --name autemix-builder --driver docker-container --bootstrap
    fi
    
    # Use the builder
    docker buildx use autemix-builder
    
    echo -e "${GREEN}Buildx setup complete${NC}"
}

# Function to build production images
build_production() {
    echo -e "${YELLOW}Building production images for ${PLATFORMS}...${NC}"
    
    # Build backend production image
    echo -e "${BLUE}Building backend production image...${NC}"
    docker buildx build \
        --platform ${PLATFORMS} \
        --build-arg VERSION=${VERSION} \
        -t ${REGISTRY}/autemix-backend:${VERSION} \
        -t ${REGISTRY}/autemix-backend:latest \
        ${PUSH_FLAG} \
        ./backend
    
    # Build frontend production image
    echo -e "${BLUE}Building frontend production image...${NC}"
    docker buildx build \
        --platform ${PLATFORMS} \
        --build-arg VERSION=${VERSION} \
        -t ${REGISTRY}/autemix-frontend:${VERSION} \
        -t ${REGISTRY}/autemix-frontend:latest \
        ${PUSH_FLAG} \
        ./frontend
    
    echo -e "${GREEN}Production images built successfully!${NC}"
}

# Function to build development images
build_development() {
    echo -e "${YELLOW}Building development images for ${PLATFORMS}...${NC}"
    
    # Build backend development image
    echo -e "${BLUE}Building backend development image...${NC}"
    docker buildx build \
        --platform ${PLATFORMS} \
        --build-arg VERSION=${VERSION}-dev \
        -f ./backend/Dockerfile.development \
        -t ${REGISTRY}/autemix-backend:dev \
        ${PUSH_FLAG} \
        ./backend
    
    # Build frontend development image
    echo -e "${BLUE}Building frontend development image...${NC}"
    docker buildx build \
        --platform ${PLATFORMS} \
        --build-arg VERSION=${VERSION}-dev \
        -f ./frontend/Dockerfile.development \
        -t ${REGISTRY}/autemix-frontend:dev \
        ${PUSH_FLAG} \
        ./frontend
    
    echo -e "${GREEN}Development images built successfully!${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [production|development|all] [--push]"
    echo "  production  - Build production images only"
    echo "  development - Build development images only"
    echo "  all         - Build both production and development images (default)"
    echo ""
    echo "Options:"
    echo "  --push      - Push images to registry after building"
    echo ""
    echo "Environment variables:"
    echo "  REGISTRY    - Docker registry prefix (default: ghcr.io/autemix)"
    echo ""
    echo "Multi-Architecture Support:"
    echo "  Builds for: linux/amd64, linux/arm64"
    echo "  Requires: Docker Buildx"
}

# Setup buildx before building
setup_buildx

# Main script logic
case "${1:-all}" in
    production)
        build_production
        ;;
    development)
        build_development
        ;;
    all)
        build_production
        build_development
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

echo -e "${GREEN}Multi-architecture build completed successfully!${NC}"
if [[ "$PUSH_FLAG" == "--push" ]]; then
    echo -e "${GREEN}Images pushed to registry: ${REGISTRY}${NC}"
else
    echo -e "${BLUE}To push images, run with --push flag${NC}"
fi