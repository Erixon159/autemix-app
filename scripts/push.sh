#!/bin/bash

# Push script for Autemix Admin Platform Docker images to GitHub Container Registry
# Usage: ./scripts/push.sh [production|development|all]
# Note: For multi-architecture images, use ./scripts/build.sh --push instead

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get version from VERSION file
VERSION=$(cat VERSION)
echo -e "${BLUE}Pushing Autemix Admin Platform v${VERSION} to registry${NC}"
echo -e "${YELLOW}Note: For multi-architecture builds, use './scripts/build.sh --push' instead${NC}"

# Default registry (can be overridden with REGISTRY env var)
REGISTRY=${REGISTRY:-"ghcr.io/autemix"}

# Check if user is logged in to GitHub Container Registry
check_login() {
    echo -e "${BLUE}Checking GitHub Container Registry login...${NC}"
    if ! docker info | grep -q "Username"; then
        echo -e "${YELLOW}Please login to GitHub Container Registry first:${NC}"
        echo "echo \$GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin"
        exit 1
    fi
}

# Function to push production images
push_production() {
    echo -e "${YELLOW}Pushing production images...${NC}"
    
    # Push backend production images
    echo -e "${BLUE}Pushing backend production images...${NC}"
    docker push ${REGISTRY}/autemix-backend:${VERSION}
    docker push ${REGISTRY}/autemix-backend:latest
    
    # Push frontend production images
    echo -e "${BLUE}Pushing frontend production images...${NC}"
    docker push ${REGISTRY}/autemix-frontend:${VERSION}
    docker push ${REGISTRY}/autemix-frontend:latest
    
    echo -e "${GREEN}Production images pushed successfully!${NC}"
}

# Function to push development images
push_development() {
    echo -e "${YELLOW}Pushing development images...${NC}"
    
    # Push backend development image
    echo -e "${BLUE}Pushing backend development image...${NC}"
    docker push ${REGISTRY}/autemix-backend:dev
    
    # Push frontend development image
    echo -e "${BLUE}Pushing frontend development image...${NC}"
    docker push ${REGISTRY}/autemix-frontend:dev
    
    echo -e "${GREEN}Development images pushed successfully!${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [production|development|all]"
    echo "  production  - Push production images only"
    echo "  development - Push development images only"
    echo "  all         - Push both production and development images (default)"
    echo ""
    echo "Environment variables:"
    echo "  REGISTRY    - Docker registry prefix (default: ghcr.io/autemix)"
    echo "  GITHUB_TOKEN - GitHub personal access token for authentication"
    echo ""
    echo "Prerequisites:"
    echo "  1. Login to GitHub Container Registry:"
    echo "     echo \$GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin"
    echo "  2. Build images first using ./scripts/build.sh"
}

# Check prerequisites
check_login

# Main script logic
case "${1:-all}" in
    production)
        push_production
        ;;
    development)
        push_development
        ;;
    all)
        push_production
        push_development
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

echo -e "${GREEN}Push completed successfully!${NC}"
