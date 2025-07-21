# Autemix Admin Platform - Deployment Guide

This guide covers Docker containerization and deployment strategies for the Autemix Admin Platform.

## Version Management

The project uses a centralized version management system with a `VERSION` file at the root. This version is propagated throughout the entire application:

- **Backend**: Available as `ENV['APP_VERSION']` in Rails
- **Frontend**: Available as `process.env.APP_VERSION` in Next.js
- **Docker Images**: Tagged with the version from `VERSION` file

### Updating Version

```bash
# Update the VERSION file
echo "1.1.0" > VERSION

# Rebuild images with new version
./scripts/build.sh
```

## Docker Images

### Production Images

- **Backend**: `ghcr.io/autemix/autemix-backend:latest`
- **Frontend**: `ghcr.io/autemix/autemix-frontend:latest`

### Development Images

- **Backend**: `ghcr.io/autemix/autemix-backend:dev`
- **Frontend**: `ghcr.io/autemix/autemix-frontend:dev`

## Multi-Architecture Support

All Docker images support multiple architectures:
- **linux/amd64** (Intel/AMD 64-bit)
- **linux/arm64** (ARM 64-bit, including Apple Silicon)

This ensures compatibility across development (Mac with Apple Silicon) and production (Linux servers) environments.

### Prerequisites for Multi-Architecture Builds

1. **Docker Buildx**: Ensure Docker Buildx is installed and enabled
   ```bash
   # Check if buildx is available
   docker buildx version
   
   # Enable buildx (if not already enabled)
   docker buildx install
   ```

2. **QEMU Emulation**: For cross-platform builds
   ```bash
   # Install QEMU emulators (on macOS with Docker Desktop, this is automatic)
   docker run --privileged --rm tonistiigi/binfmt --install all
   ```

The build scripts automatically handle buildx setup, but manual setup may be required in CI/CD environments.

## Building Images

### Using Build Scripts (Recommended)

```bash
# Build all images for multiple architectures (production + development)
./scripts/build.sh

# Build and push to registry in one step
./scripts/build.sh --push

# Build only production images
./scripts/build.sh production

# Build only development images
./scripts/build.sh development

# Build production images and push to registry
./scripts/build.sh production --push
```

### Manual Multi-Architecture Building

```bash
# Setup buildx builder (one-time setup)
docker buildx create --name autemix-builder --driver docker-container --bootstrap
docker buildx use autemix-builder

# Backend production (multi-arch)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg VERSION=$(cat VERSION) \
  -t ghcr.io/autemix/autemix-backend:$(cat VERSION) \
  --push ./backend

# Frontend production (multi-arch)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg VERSION=$(cat VERSION) \
  -t ghcr.io/autemix/autemix-frontend:$(cat VERSION) \
  --push ./frontend
```

### Single Architecture Building (Local Development)

```bash
# Backend production (current architecture only)
docker build --build-arg VERSION=$(cat VERSION) -t autemix-backend:$(cat VERSION) ./backend

# Frontend production (current architecture only)
docker build --build-arg VERSION=$(cat VERSION) -t autemix-frontend:$(cat VERSION) ./frontend

# Development images (current architecture only)
docker build -f ./backend/Dockerfile.development --build-arg VERSION=$(cat VERSION)-dev -t autemix-backend:dev ./backend
docker build -f ./frontend/Dockerfile.development --build-arg VERSION=$(cat VERSION)-dev -t autemix-frontend:dev ./frontend
```

## Pushing to Registry

### Using Push Scripts

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin

# Push all images
./scripts/push.sh

# Push only production images
./scripts/push.sh production
```

### Manual Pushing

```bash
# Tag and push backend
docker tag autemix-backend:$(cat VERSION) ghcr.io/autemix/autemix-backend:$(cat VERSION)
docker push ghcr.io/autemix/autemix-backend:$(cat VERSION)

# Tag and push frontend
docker tag autemix-frontend:$(cat VERSION) ghcr.io/autemix/autemix-frontend:$(cat VERSION)
docker push ghcr.io/autemix/autemix-frontend:$(cat VERSION)
```

## Deployment Environments

### Development

```bash
# Start services only (PostgreSQL + Redis)
docker compose up -d

# Run backend and frontend locally
cd backend && bundle exec rails server -p 3001
cd frontend && npm run dev
```

### Development with Docker

```bash
# Uncomment backend-dev and frontend-dev services in docker-compose.yml
docker compose up -d
```

### Production

```bash
# Set environment variables
export VERSION=$(cat VERSION)
export POSTGRES_PASSWORD=your_secure_password
export RAILS_MASTER_KEY=your_rails_master_key
export SECRET_KEY_BASE=your_secret_key_base

# Deploy with production compose
docker compose -f docker-compose.prod.yml up -d
```

## Environment Variables

### Required for Production

- `POSTGRES_PASSWORD`: PostgreSQL password
- `RAILS_MASTER_KEY`: Rails master key for encrypted credentials
- `SECRET_KEY_BASE`: Rails secret key base
- `VERSION`: Application version (defaults to latest)
- `REGISTRY`: Docker registry prefix (defaults to ghcr.io/autemix)

### Optional

- `POSTGRES_USER`: PostgreSQL username (defaults to autemix)
- `NEXT_PUBLIC_API_URL`: Frontend API URL (defaults to http://localhost:3001)

## Health Checks

Both services include health check endpoints:

- **Backend**: `GET /health`
- **Frontend**: `GET /api/health`

Health checks verify:
- Service availability
- Database connectivity (backend)
- Application version
- Environment status

## Monitoring

### Container Health

```bash
# Check container health status
docker compose ps

# View health check logs
docker compose logs backend
docker compose logs frontend
```

### Application Logs

```bash
# Follow all logs
docker compose logs -f

# Follow specific service logs
docker compose logs -f backend
docker compose logs -f frontend
```

## Scaling

### Horizontal Scaling

```bash
# Scale backend instances
docker compose -f docker-compose.prod.yml up -d --scale backend=3

# Scale frontend instances
docker compose -f docker-compose.prod.yml up -d --scale frontend=2
```

### Load Balancing

The production setup includes an optional Nginx reverse proxy for load balancing and SSL termination.

## Security Considerations

1. **Non-root users**: All containers run as non-root users
2. **Health checks**: Proper health monitoring for all services
3. **Secret management**: Environment variables for sensitive data
4. **Network isolation**: Services communicate through Docker networks
5. **Image optimization**: Multi-stage builds for minimal attack surface

## Troubleshooting

### Common Issues

1. **Health check failures**: Check service logs and database connectivity
2. **Build failures**: Ensure all dependencies are available
3. **Registry authentication**: Verify GitHub token permissions
4. **Version mismatches**: Ensure VERSION file is up to date

### Debug Commands

```bash
# Check image versions
docker images | grep autemix

# Inspect container configuration
docker inspect <container_name>

# Execute commands in running containers
docker compose exec backend rails console
docker compose exec frontend sh
```
