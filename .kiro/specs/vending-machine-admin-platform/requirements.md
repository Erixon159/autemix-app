# Requirements Document

## Introduction

The Vending Machine Admin Platform is a comprehensive BFF-based system designed to manage vending machines that sell perfume vials. The platform consists of a Ruby on Rails 8 API-only backend and a Next.js 15 frontend application, orchestrated via Docker Compose. The system supports multi-tenancy with role-based access control, real-time inventory management, maintenance tracking, and automated alerting capabilities.

## Requirements

### Requirement 1: Multi-Tenant Authentication System

**User Story:** As a platform operator, I want a secure multi-tenant authentication system with role-based access control, so that different organizations can manage their vending machines independently with appropriate permission levels.

#### Acceptance Criteria

1. WHEN an admin logs in THEN the system SHALL authenticate via hybrid JWT + session approach providing full platform access
2. WHEN a technician logs in THEN the system SHALL authenticate via hybrid JWT + session approach providing restricted access to maintenance and refill operations only
3. WHEN the BFF communicates with the backend THEN it SHALL use JWT tokens in Authorization headers for stateless API authentication
4. WHEN authentication cookies are set THEN they SHALL be HttpOnly, Secure, and SameSite=Strict for browser session persistence
5. WHEN JWT tokens are issued THEN they SHALL have 24-hour expiration with JTI-based revocation capability
6. WHEN a user logs out THEN the system SHALL revoke the JWT token and clear the session cookie
7. WHEN a vending machine makes an API request THEN the system SHALL authenticate via encrypted API key and allow write-only access to logs and inventory
8. IF a user belongs to a tenant THEN the system SHALL scope all data access to that tenant's resources only
9. WHEN an API key is stored THEN it SHALL be encrypted in the database using Rails message verifier
10. WHEN JWT tokens are revoked THEN the system SHALL use JTIMatcher strategy to invalidate tokens immediately

### Requirement 2: Vending Machine Management

**User Story:** As an admin, I want to manage vending machines across multiple locations, so that I can track their status, location, and operational history.

#### Acceptance Criteria

1. WHEN creating a vending machine THEN the system SHALL generate a unique UUID and encrypted API key
2. WHEN viewing machine details THEN the system SHALL display name, location, installation date, last refill date, and last maintenance date
3. WHEN a machine sends a heartbeat ping THEN the system SHALL update the machine's last contact timestamp
4. IF a machine misses expected pings THEN the system SHALL generate an alert for offline status
5. WHEN updating machine information THEN the system SHALL validate all required fields and maintain audit trail

### Requirement 3: Inventory Management System

**User Story:** As an admin or technician, I want to track perfume inventory across all vending machines, so that I can ensure adequate stock levels and prevent stockouts.

#### Acceptance Criteria

1. WHEN viewing machine inventory THEN the system SHALL display current stock levels for each perfume variant
2. WHEN inventory falls below threshold THEN the system SHALL automatically generate low stock alerts
3. WHEN a sale occurs THEN the system SHALL decrement inventory quantities in real-time
4. WHEN restocking a machine THEN technicians SHALL be able to update inventory quantities with timestamp tracking
5. WHEN viewing inventory history THEN the system SHALL show stock movements with dates and responsible parties

### Requirement 4: Sales Transaction Logging

**User Story:** As a vending machine, I want to log sales transactions automatically, so that inventory and revenue tracking remains accurate and up-to-date.

#### Acceptance Criteria

1. WHEN a sale occurs THEN the machine SHALL POST transaction data including perfume ID, quantity, and timestamp
2. WHEN receiving sale data THEN the system SHALL validate machine authentication and update inventory accordingly
3. WHEN processing sales THEN the system SHALL log transaction details for reporting and audit purposes
4. IF inventory reaches zero THEN the system SHALL prevent further sales of that perfume variant
5. WHEN sales data is recorded THEN the system SHALL update remaining stock calculations immediately

### Requirement 5: Maintenance and Service Management

**User Story:** As a technician, I want to log maintenance activities and track service history, so that machine uptime and performance can be optimized.

#### Acceptance Criteria

1. WHEN performing maintenance THEN technicians SHALL log activity type, notes, cost, and supporting photos
2. WHEN maintenance is due THEN the system SHALL generate scheduled maintenance alerts
3. WHEN viewing maintenance history THEN the system SHALL display chronological service records per machine
4. WHEN uploading maintenance photos THEN the system SHALL store them securely using ActiveStorage
5. IF maintenance is overdue THEN the system SHALL escalate alert priority and notify administrators

### Requirement 6: Alert and Notification System

**User Story:** As an admin, I want automated alerts for critical events, so that I can proactively address issues before they impact operations.

#### Acceptance Criteria

1. WHEN stock levels fall below threshold THEN the system SHALL generate low stock alerts
2. WHEN machines miss heartbeat pings THEN the system SHALL create offline machine alerts
3. WHEN maintenance schedules are due THEN the system SHALL generate service reminder alerts
4. WHEN alerts are created THEN the system SHALL optionally send email notifications via background jobs
5. WHEN viewing alerts THEN users SHALL be able to mark them as read and filter by status or type

### Requirement 7: Multi-Tenant Data Isolation

**User Story:** As a platform operator, I want complete data isolation between tenants, so that each organization's data remains secure and private.

#### Acceptance Criteria

1. WHEN a user accesses the system THEN all data queries SHALL be automatically scoped to their tenant
2. WHEN API requests are made THEN tenant context SHALL be determined via subdomain or header
3. WHEN creating resources THEN they SHALL be automatically associated with the current tenant
4. IF a user attempts cross-tenant access THEN the system SHALL deny access and log the attempt
5. WHEN switching tenant context THEN all cached data SHALL be invalidated and refreshed

### Requirement 8: RESTful API Architecture

**User Story:** As a frontend developer, I want a well-structured RESTful API, so that I can build responsive user interfaces with predictable data access patterns.

#### Acceptance Criteria

1. WHEN making API requests THEN the system SHALL follow RESTful conventions for all endpoints
2. WHEN returning data THEN the API SHALL use consistent JSON serialization format
3. WHEN errors occur THEN the API SHALL return appropriate HTTP status codes with descriptive messages
4. WHEN handling authentication THEN the API SHALL support JWT tokens, session cookies, and API key methods
5. WHEN processing BFF requests THEN the API SHALL authenticate via JWT tokens in Authorization headers
6. WHEN processing machine requests THEN the API SHALL authenticate via encrypted API keys
7. WHEN JWT authentication fails THEN the API SHALL return 401 Unauthorized with token refresh guidance
8. WHEN processing requests THEN the API SHALL validate input data and return validation errors clearly

### Requirement 9: Frontend Dashboard Interface

**User Story:** As an admin or technician, I want an intuitive web dashboard, so that I can efficiently manage machines, view reports, and respond to alerts.

#### Acceptance Criteria

1. WHEN accessing the dashboard THEN the system SHALL display machine status overview with visual indicators
2. WHEN viewing machine details THEN the interface SHALL show inventory, maintenance history, and recent sales
3. WHEN alerts are present THEN they SHALL be prominently displayed with appropriate urgency indicators
4. WHEN performing actions THEN the interface SHALL provide immediate feedback and confirmation
5. WHEN using mobile devices THEN the interface SHALL be responsive and touch-friendly

### Requirement 10: Development and Deployment Infrastructure

**User Story:** As a developer, I want containerized development and deployment setup, so that the application can be consistently deployed across different environments.

#### Acceptance Criteria

1. WHEN starting development THEN Docker Compose SHALL orchestrate all services with proper networking
2. WHEN deploying applications THEN containers SHALL be configured with appropriate environment variables
3. WHEN running tests THEN the system SHALL provide isolated test databases and consistent test data
4. WHEN scaling services THEN the architecture SHALL support horizontal scaling of backend and frontend components
5. WHEN monitoring applications THEN logs SHALL be centralized and accessible for debugging and analysis