# Autemix Admin Platform

A comprehensive admin platform for Autemix - managing vending machines, inventory, and operations.

## Architecture

This is a monorepo containing:
- **Backend**: Rails 8 API (Ruby 3.4.3) - Port 3001
- **Frontend**: Next.js 15 with TypeScript and Tailwind CSS - Port 3000

## Quick Start

### Prerequisites
- Ruby 3.4.3
- Node.js 18+
- Docker & Docker Compose
- npm or yarn

### Setup
```bash
# Start Docker services (PostgreSQL & Redis)
docker compose up -d

# Setup backend
cd backend
bundle install
bundle exec rails db:create db:migrate

# Setup frontend  
cd ../frontend
npm install
```

### Development
```bash
# Terminal 1: Start Docker services
docker compose up -d

# Terminal 2: Start Rails API (from backend/)
bundle exec rails server -p 3001

# Terminal 3: Start Next.js app (from frontend/)
npm run dev
```

### Docker Services
- **PostgreSQL**: localhost:5432 (user: postgres, password: password)
- **Redis**: localhost:6379

```bash
# Manage Docker services
docker compose up -d     # Start services
docker compose down      # Stop services  
docker compose logs -f   # View logs
```

## Development

- Backend API: http://localhost:3001
- Frontend App: http://localhost:3000
- API Documentation: http://localhost:3001/api-docs (when implemented)

## Testing

```bash
# Run all tests
npm run test

# Backend tests only
npm run test:backend

# Frontend tests only  
npm run test:frontend
```

## Deployment

TBD - Will be configured for containerized deployment