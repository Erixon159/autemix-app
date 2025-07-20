# Implementation Plan

- [x] 1. Set up project structure and development environment
  - Create monorepo directory structure with backend/ and frontend/ folders
  - Initialize Rails 8 API-only application in backend/ directory
  - Initialize Next.js 15 application with App Router in frontend/ directory
  - Create Docker Compose configuration for development orchestration
  - Set up PostgreSQL and Redis services in Docker Compose
  - Configure environment variables and secrets management
  - _Requirements: 10.1, 10.2_

- [x] 2. Implement comprehensive Docker containerization strategy
  - Create production Dockerfiles for both backend (Rails) and frontend (Next.js)
  - Create development Dockerfiles (Dockerfile.development) for local development
  - Implement centralized version management system with VERSION file
  - Create build scripts for automated image building and tagging
  - Configure GitHub Container Registry for image storage and distribution
  - Create Docker Compose configurations for different environments (dev, staging, prod)
  - Implement multi-stage builds for optimized production images
  - Add health checks and proper signal handling in containers
  - Create deployment scripts and documentation for container orchestration
  - _Requirements: 10.1, 10.2, 10.5_

- [ ] 3. Configure Rails backend foundation
  - Configure Rails for API-only mode with CORS settings
  - Add and configure essential gems (devise, acts_as_tenant, jsonapi-serializer, sidekiq)
  - Set up database configuration for PostgreSQL
  - Configure Redis for background jobs and caching
  - Create database migration for initial schema structure
  - _Requirements: 8.1, 8.2, 7.1_

- [ ] 4. Implement multi-tenant foundation
  - Create Tenant model with validations and subdomain support
  - Configure acts_as_tenant gem for automatic scoping
  - Implement tenant resolution middleware for subdomain/header detection
  - Create tenant switching functionality with proper context management
  - Write unit tests for tenant model and scoping behavior
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 5. Build authentication system foundation
  - Configure Devise for Admin and Technician models
  - Implement secure cookie session configuration (HttpOnly, Secure, SameSite)
  - Create custom API key authentication middleware for vending machines
  - Implement API key encryption and storage using Rails encryption
  - Write authentication unit tests and integration tests
  - _Requirements: 1.1, 1.2, 1.5, 1.6_

- [ ] 6. Create core data models
  - Implement Admin model with Devise integration and tenant association
  - Implement Technician model with limited permissions and tenant scoping
  - Create VendingMachine model with UUID, encrypted API keys, and status tracking
  - Implement Perfume model with brand, description, and ml specifications
  - Write comprehensive model unit tests with FactoryBot factories
  - _Requirements: 2.2, 2.5, 3.4, 4.4_

- [ ] 7. Implement inventory management models
  - Create InventoryItem model linking perfumes to vending machines
  - Implement stock quantity tracking with low stock threshold logic
  - Create inventory scoping and validation rules
  - Implement inventory update methods with transaction safety
  - Write unit tests for inventory calculations and stock management
  - _Requirements: 3.1, 3.2, 3.4, 3.5_

- [ ] 8. Build transaction logging system
  - Create SaleLog model for recording vending machine transactions
  - Implement automatic inventory decrement on sale recording
  - Create validation rules for sale data integrity
  - Implement transaction rollback for failed inventory updates
  - Write unit tests for sale logging and inventory updates
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 9. Implement maintenance tracking system
  - Create MaintenanceLog model with polymorphic technician association
  - Implement ActiveStorage integration for maintenance photos
  - Create maintenance type enumeration and cost tracking
  - Implement maintenance scheduling and due date calculations
  - Write unit tests for maintenance logging and photo attachments
  - _Requirements: 5.1, 5.3, 5.4_

- [ ] 10. Build alert and notification system
  - Create Alert model with priority levels and alert types
  - Implement AlertService for generating low stock alerts
  - Create MachineHealthCheckJob for monitoring offline machines
  - Implement maintenance due date alert generation
  - Create AlertNotificationJob for email notifications via Sidekiq
  - Write unit tests for alert generation and background job processing
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 5.2_

- [ ] 11. Create RESTful API endpoints for authentication
  - Implement sessions controller for login/logout functionality
  - Create /api/v1/sessions endpoints with proper error handling
  - Implement /api/v1/me endpoint for current user context
  - Add request validation and structured error responses
  - Write integration tests for authentication endpoints
  - _Requirements: 8.1, 8.3, 8.4, 1.1, 1.2_

- [ ] 12. Implement vending machine API endpoints
  - Create VendingMachinesController with CRUD operations
  - Implement tenant-scoped machine queries and updates
  - Create machine heartbeat ping endpoint for status updates
  - Add machine-specific inventory and maintenance log endpoints
  - Write integration tests for machine management endpoints
  - _Requirements: 8.1, 2.1, 2.3, 2.4, 8.5_

- [ ] 13. Build inventory management API endpoints
  - Create InventoryController for stock level management
  - Implement inventory update endpoints with validation
  - Create low stock alert triggering on inventory changes
  - Add inventory history and movement tracking endpoints
  - Write integration tests for inventory management operations
  - _Requirements: 3.1, 3.2, 3.4, 3.5, 8.1_

- [ ] 14. Implement sales transaction API endpoints
  - Create SalesController for machine transaction logging
  - Implement API key authentication for machine-only access
  - Add automatic inventory updates on sale recording
  - Create sales reporting and history endpoints
  - Write integration tests for sales transaction processing
  - _Requirements: 4.1, 4.2, 4.3, 4.5, 1.3_

- [ ] 15. Create maintenance and alert API endpoints
  - Implement MaintenanceLogsController for service record management
  - Create AlertsController for alert management and marking as read
  - Add photo upload handling for maintenance records
  - Implement alert filtering and priority-based sorting
  - Write integration tests for maintenance and alert endpoints
  - _Requirements: 5.1, 5.3, 6.5, 8.1_

- [ ] 15. Set up Next.js frontend foundation
  - Configure Next.js 15 with App Router and TypeScript
  - Set up TailwindCSS and shadcn/ui component library
  - Create authentication middleware for route protection
  - Implement API client service for backend communication
  - Configure environment variables for API endpoints
  - _Requirements: 9.4, 8.2_

- [ ] 16. Implement frontend authentication system
  - Create login page with form validation using React Hook Form
  - Implement AuthService for session management and API calls
  - Create authentication middleware for protected routes
  - Build user context provider for application state
  - Add automatic session refresh and logout handling
  - Write unit tests for authentication components and services
  - _Requirements: 1.1, 1.2, 9.4_

- [ ] 17. Build main dashboard interface
  - Create dashboard layout with navigation and user context
  - Implement machine status overview with visual indicators
  - Create alert notification display with priority indicators
  - Add quick action buttons for common operations
  - Implement responsive design for mobile compatibility
  - Write component tests for dashboard functionality
  - _Requirements: 9.1, 9.3, 9.5_

- [ ] 18. Create machine management interface
  - Build machine list view with status indicators and search
  - Create machine detail view with inventory and maintenance history
  - Implement machine creation and editing forms
  - Add machine status monitoring with real-time updates
  - Create machine-specific alert display and management
  - Write component tests for machine management features
  - _Requirements: 2.1, 2.2, 2.4, 9.1, 9.2_

- [ ] 19. Implement inventory management interface
  - Create inventory grid component with stock level indicators
  - Build inventory update forms with validation
  - Implement low stock highlighting and alert integration
  - Add inventory history and movement tracking views
  - Create bulk inventory update functionality for technicians
  - Write component tests for inventory management components
  - _Requirements: 3.1, 3.2, 3.4, 3.5, 9.2_

- [ ] 20. Build maintenance tracking interface
  - Create maintenance log entry forms with photo upload
  - Implement maintenance history display with filtering
  - Build maintenance scheduling and due date tracking
  - Add maintenance cost tracking and reporting
  - Create technician-specific maintenance views with restricted access
  - Write component tests for maintenance tracking features
  - _Requirements: 5.1, 5.3, 5.4, 9.2_

- [ ] 21. Create alert and notification interface
  - Build alert dashboard with priority-based sorting
  - Implement alert detail views with action buttons
  - Create alert filtering and search functionality
  - Add alert acknowledgment and resolution tracking
  - Implement real-time alert updates using polling or WebSockets
  - Write component tests for alert management interface
  - _Requirements: 6.1, 6.2, 6.3, 6.5, 9.3_

- [ ] 22. Implement role-based access control
  - Create permission checking utilities for frontend components
  - Implement admin-only features and interface elements
  - Add technician-restricted views for maintenance operations
  - Create role-based navigation and menu systems
  - Add permission-based API endpoint protection
  - Write integration tests for role-based access scenarios
  - _Requirements: 1.1, 1.2, 7.4_

- [ ] 23. Add comprehensive error handling
  - Implement global error boundary for React application
  - Create structured error display components
  - Add API error handling with user-friendly messages
  - Implement retry mechanisms for failed requests
  - Create error logging and reporting system
  - Write tests for error handling scenarios
  - _Requirements: 8.3, 9.4_

- [ ] 24. Create background job monitoring
  - Implement Sidekiq web interface for job monitoring
  - Create job failure handling and retry logic
  - Add job performance monitoring and alerting
  - Implement job queue health checks
  - Create administrative interface for job management
  - Write tests for background job processing
  - _Requirements: 6.4, 10.5_

- [ ] 25. Implement comprehensive testing suite
  - Create RSpec test suite with FactoryBot factories for all models
  - Write integration tests for all API endpoints with authentication
  - Implement frontend component tests using Jest and React Testing Library
  - Create end-to-end tests using Playwright for critical user flows
  - Add test coverage reporting and quality gates
  - Set up continuous integration pipeline for automated testing
  - _Requirements: 10.3, 10.4_

- [ ] 26. Set up production deployment configuration
  - Create production Docker Compose configuration
  - Configure environment-specific settings and secrets
  - Set up database migration and seeding scripts
  - Implement health check endpoints for monitoring
  - Create backup and recovery procedures
  - Configure logging and monitoring for production environment
  - _Requirements: 10.1, 10.2, 10.5_