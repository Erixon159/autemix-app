#!/bin/bash

# Test script for Autemix Admin Platform
# Usage: ./scripts/test.sh [backend|frontend|all] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to run backend tests
test_backend() {
    echo -e "${BLUE}Running backend tests (RSpec)...${NC}"
    docker compose exec -e DATABASE_HOST=postgres backend-dev bundle exec rspec --format documentation "$@"
    echo -e "${GREEN}Backend tests completed!${NC}"
}

# Function to run frontend tests (when implemented)
test_frontend() {
    echo -e "${BLUE}Running frontend tests...${NC}"
    docker compose exec frontend-dev npm test "$@"
    echo -e "${GREEN}Frontend tests completed!${NC}"
}

# Function to run all tests
test_all() {
    echo -e "${BLUE}Running all tests...${NC}"
    test_backend "$@"
    # test_frontend "$@"  # Uncomment when frontend tests are ready
    echo -e "${GREEN}All tests completed!${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [backend|frontend|all] [rspec-options]"
    echo "  backend   - Run backend RSpec tests"
    echo "  frontend  - Run frontend tests (not implemented yet)"
    echo "  all       - Run all tests (default)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Run all tests"
    echo "  $0 backend                   # Run backend tests"
    echo "  $0 backend --tag focus       # Run focused backend tests"
    echo "  $0 backend spec/jobs/        # Run only job tests"
}

# Main script logic
case "${1:-all}" in
    backend)
        shift
        test_backend "$@"
        ;;
    frontend)
        shift
        test_frontend "$@"
        ;;
    all)
        shift
        test_all "$@"
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