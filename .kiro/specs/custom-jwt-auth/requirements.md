# Custom JWT + Cookies Authentication Requirements

## Introduction

This feature implements a custom JWT-based authentication system using HTTP-only cookies for the Autemix Admin Platform. The system will replace Devise with a transparent, controllable authentication flow that supports multi-tenancy and provides clear separation between admin and technician authentication.

## Requirements

### Requirement 1: Remove Devise Dependencies

**User Story:** As a developer, I want to remove all Devise-related code and dependencies so that we have a clean foundation for custom authentication while preserving existing API key authentication for vending machines.

#### Acceptance Criteria

1. WHEN removing Devise THEN the system SHALL remove the devise and devise-jwt gems from the Gemfile
2. WHEN removing Devise THEN the system SHALL remove all Devise-specific code from models (Admin and Technician)
3. WHEN removing Devise THEN the system SHALL remove Devise initializer configuration
4. WHEN removing Devise THEN the system SHALL remove Devise routes and controllers
5. WHEN removing Devise THEN the system SHALL remove Devise-specific database columns (jti, encrypted_password, etc.)
6. WHEN removing Devise THEN the system SHALL ensure the application still boots without errors
7. WHEN removing Devise THEN the system SHALL preserve existing API key authentication functionality for vending machines

### Requirement 2: Implement Custom User Models

**User Story:** As a developer, I want clean Admin and Technician models with custom password handling so that authentication logic is transparent and controllable.

#### Acceptance Criteria

1. WHEN implementing custom models THEN Admin model SHALL have secure password handling using bcrypt
2. WHEN implementing custom models THEN Technician model SHALL have secure password handling using bcrypt
3. WHEN implementing custom models THEN both models SHALL maintain multi-tenant support with acts_as_tenant
4. WHEN implementing custom models THEN both models SHALL have password validation (minimum length, complexity if needed)
5. WHEN implementing custom models THEN both models SHALL have email validation and uniqueness within tenant scope
6. WHEN implementing custom models THEN both models SHALL support account locking after failed attempts
7. WHEN implementing custom models THEN both models SHALL track login attempts and timestamps

### Requirement 3: JWT Token Management

**User Story:** As a developer, I want a robust JWT token system so that user sessions are secure and manageable.

#### Acceptance Criteria

1. WHEN generating JWT tokens THEN the system SHALL use a secure secret key from Rails credentials
2. WHEN generating JWT tokens THEN tokens SHALL include user ID, tenant ID, user type (admin/technician), and expiration
3. WHEN generating JWT tokens THEN tokens SHALL have a reasonable expiration time (24 hours)
4. WHEN validating JWT tokens THEN the system SHALL verify signature, expiration, and user existence
5. WHEN validating JWT tokens THEN the system SHALL set proper tenant context based on token data
6. WHEN revoking tokens THEN the system SHALL support token blacklisting for logout functionality
7. WHEN refreshing tokens THEN the system SHALL provide a mechanism to refresh tokens before expiration

### Requirement 4: HTTP-Only Cookie Implementation

**User Story:** As a security-conscious developer, I want JWT tokens stored in HTTP-only cookies so that they are protected from XSS attacks.

#### Acceptance Criteria

1. WHEN setting authentication cookies THEN cookies SHALL be HTTP-only to prevent JavaScript access
2. WHEN setting authentication cookies THEN cookies SHALL be secure in production (HTTPS only)
3. WHEN setting authentication cookies THEN cookies SHALL have SameSite=Strict for CSRF protection
4. WHEN setting authentication cookies THEN cookies SHALL have appropriate expiration matching JWT expiration
5. WHEN clearing authentication cookies THEN logout SHALL properly clear all authentication cookies
6. WHEN handling cookies THEN the system SHALL support both development (HTTP) and production (HTTPS) environments

### Requirement 5: Authentication Controllers

**User Story:** As a frontend developer, I want clear authentication endpoints so that I can implement login/logout functionality in the Next.js application.

#### Acceptance Criteria

1. WHEN implementing login endpoint THEN POST /api/v1/auth/admin/login SHALL authenticate admin users
2. WHEN implementing login endpoint THEN POST /api/v1/auth/technician/login SHALL authenticate technician users
3. WHEN implementing logout endpoint THEN DELETE /api/v1/auth/logout SHALL work for both user types
4. WHEN authenticating successfully THEN the system SHALL return user data and set authentication cookie
5. WHEN authentication fails THEN the system SHALL return appropriate error messages and increment failed attempts
6. WHEN account is locked THEN the system SHALL return account locked error and prevent further attempts
7. WHEN logging out THEN the system SHALL revoke the token and clear the authentication cookie

### Requirement 6: Multi-Tenant Authentication

**User Story:** As a platform administrator, I want authentication to respect tenant boundaries so that users can only access their own tenant's data.

#### Acceptance Criteria

1. WHEN authenticating users THEN the system SHALL set tenant context based on the authenticated user
2. WHEN validating tokens THEN the system SHALL verify that the user belongs to the expected tenant
3. WHEN switching tenants THEN users SHALL be required to re-authenticate
4. WHEN tenant context is missing THEN API requests SHALL be rejected with appropriate error
5. WHEN user is deleted or deactivated THEN their tokens SHALL be invalidated

### Requirement 7: Account Security Features

**User Story:** As a security administrator, I want account protection features so that user accounts are protected from brute force attacks.

#### Acceptance Criteria

1. WHEN failed login attempts exceed threshold THEN the account SHALL be temporarily locked
2. WHEN account is locked THEN the system SHALL prevent login attempts for a specified duration
3. WHEN successful login occurs THEN failed attempt counter SHALL be reset
4. WHEN account lockout expires THEN the user SHALL be able to attempt login again
5. WHEN tracking login attempts THEN the system SHALL log IP addresses and timestamps
6. WHEN detecting suspicious activity THEN the system SHALL provide audit trail information

### Requirement 8: API Authentication Middleware

**User Story:** As a backend developer, I want authentication middleware so that protected endpoints automatically verify user authentication while coexisting with existing API key authentication for vending machines.

#### Acceptance Criteria

1. WHEN implementing middleware THEN it SHALL extract JWT from HTTP-only cookies for admin/technician requests
2. WHEN implementing middleware THEN it SHALL validate JWT signature and expiration
3. WHEN implementing middleware THEN it SHALL set current_user and tenant context
4. WHEN token is invalid THEN middleware SHALL return 401 Unauthorized
5. WHEN token is expired THEN middleware SHALL return 401 with specific expiration error
6. WHEN user is not found THEN middleware SHALL return 401 and invalidate token
7. WHEN middleware succeeds THEN protected controllers SHALL have access to current_user and current_tenant
8. WHEN request is to /api/v1/machines/* endpoints THEN middleware SHALL defer to existing API key authentication
9. WHEN API key authentication is present THEN JWT authentication SHALL be skipped

### Requirement 9: Testing Infrastructure

**User Story:** As a developer, I want comprehensive tests so that the authentication system is reliable and maintainable.

#### Acceptance Criteria

1. WHEN testing authentication THEN tests SHALL cover successful login scenarios for both user types
2. WHEN testing authentication THEN tests SHALL cover failed login scenarios and error handling
3. WHEN testing authentication THEN tests SHALL cover account lockout and unlock scenarios
4. WHEN testing authentication THEN tests SHALL cover JWT token validation and expiration
5. WHEN testing authentication THEN tests SHALL cover multi-tenant authentication scenarios
6. WHEN testing authentication THEN tests SHALL cover logout and token revocation
7. WHEN testing authentication THEN tests SHALL use factories and helpers for consistent test data