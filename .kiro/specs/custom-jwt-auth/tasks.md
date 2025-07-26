# Custom JWT + Cookies Authentication Implementation Plan

- [x] 1. Remove Devise dependencies and clean up existing code
  - Remove devise and devise-jwt gems from Gemfile
  - Remove Devise initializer configuration file
  - Remove Devise routes and session controllers
  - Remove Devise-specific code from Admin and Technician models
  - Preserve existing API key authentication functionality
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.7_

- [x] 2. Create database migration to remove Devise columns and add custom authentication fields
  - Remove Devise-specific columns (encrypted_password, jti, reset_password_token, etc.)
  - Add password_digest column for bcrypt integration
  - Add failed_attempts, locked_at, last_login_at, last_login_ip columns
  - Run migration and verify database schema
  - _Requirements: 1.5, 2.7, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 3. Implement custom Admin and Technician models with secure password handling
  - Add has_secure_password to both models
  - Implement password validation (minimum 8 characters)
  - Add email validation with tenant-scoped uniqueness
  - Implement account lockout methods (lock_account!, unlock_account!, account_locked?)
  - Implement failed attempt tracking methods
  - Write comprehensive model tests
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7_

- [ ] 4. Create JWT service for token management
  - Implement JwtService.encode method with user_id, tenant_id, user_type payload
  - Implement JwtService.decode method with signature and expiration validation
  - Integrate with Redis-based token blacklisting (blacklist_token, token_blacklisted?)
  - Use Rails credentials for JWT secret key
  - Write comprehensive JWT service tests
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

- [ ] 5. Create TokenBlacklistService for Redis-based JWT revocation
  - Implement TokenBlacklistService with Redis backend
  - Add blacklist_token method with automatic TTL expiration
  - Add token_blacklisted? method for fast lookups
  - Implement automatic cleanup using Redis TTL
  - Write service tests for blacklist functionality
  - _Requirements: 3.6, 3.7_

- [ ] 6. Implement Cookie service for secure HTTP-only cookie management
  - Create CookieService.set_auth_cookie method with security flags
  - Create CookieService.clear_auth_cookie method
  - Implement environment-aware cookie settings (HTTP vs HTTPS)
  - Set HTTP-only, Secure, and SameSite=Strict flags appropriately
  - Write cookie service tests for different environments
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6_

- [ ] 7. Create Authentication service for credential validation and user authentication
  - Implement AuthenticationService.authenticate_admin method
  - Implement AuthenticationService.authenticate_technician method
  - Implement AuthenticationService.logout_user method
  - Add failed attempt handling and account lockout logic
  - Add IP address tracking for security auditing
  - Return structured response objects with success/failure status
  - Write comprehensive authentication service tests
  - _Requirements: 2.6, 2.7, 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ] 8. Implement authentication controllers for login/logout endpoints
  - Create AdminAuthController with login and logout actions
  - Create TechnicianAuthController with login and logout actions
  - Implement proper error handling and response formatting
  - Set authentication cookies on successful login
  - Clear cookies on logout and blacklist tokens
  - Add tenant context setting during authentication
  - Write controller tests for all authentication scenarios
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7_

- [ ] 9. Create JWT authentication middleware
  - Implement JwtAuthentication middleware class
  - Add token extraction from HTTP-only cookies
  - Add JWT validation and user lookup
  - Set current_user and tenant context for authenticated requests
  - Skip JWT authentication for /api/v1/machines/* endpoints
  - Defer to existing API key authentication when appropriate
  - Handle authentication errors with proper HTTP status codes
  - Write middleware tests for all scenarios
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9_

- [ ] 10. Update ApplicationController to integrate with new authentication system
  - Remove Devise-specific authentication helpers
  - Add current_user and current_tenant helper methods
  - Update authenticate_request! method to work with JWT middleware
  - Preserve existing API key authentication for vending machines
  - Ensure tenant context is properly set for all request types
  - Write integration tests for controller authentication
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 8.7_

- [ ] 11. Configure routes for new authentication endpoints
  - Add routes for admin login/logout endpoints
  - Add routes for technician login/logout endpoints
  - Remove old Devise routes
  - Ensure API key routes for machines remain unchanged
  - Test route generation and path helpers
  - _Requirements: 5.1, 5.2, 5.3_

- [ ] 12. Create comprehensive test suite for authentication system
  - Write request specs for login/logout flows
  - Write integration tests for protected endpoint access
  - Write security tests for cookie handling and JWT validation
  - Write multi-tenant authentication tests
  - Write account lockout and security feature tests
  - Create test factories and helpers for authentication testing
  - Ensure all edge cases and error scenarios are covered
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7_

- [ ] 13. Add error handling and custom exception classes
  - Create custom authentication exception classes
  - Implement proper error response formatting
  - Add error handling for token expiration, invalid tokens, account lockout
  - Ensure error messages are user-friendly and secure
  - Write tests for all error scenarios
  - _Requirements: 5.5, 5.6, 5.7, 8.4, 8.5, 8.6_

- [ ] 14. Implement security features and audit logging
  - Add IP address tracking for login attempts
  - Implement audit logging for authentication events
  - Add rate limiting considerations for login endpoints
  - Implement automatic cleanup of expired tokens
  - Add security headers for authentication responses
  - Write tests for security features
  - _Requirements: 7.5, 7.6_

- [ ] 15. Update existing tests and remove Devise-related test code
  - Remove Devise test helpers and configurations
  - Update existing controller and integration tests
  - Replace Devise authentication in tests with custom JWT authentication
  - Ensure all existing functionality still works with new authentication
  - Update test factories to work with new password system
  - _Requirements: 1.6, 9.7_

- [ ] 16. Performance optimization and caching
  - Add caching for frequently accessed user data
  - Optimize database queries for authentication
  - Implement efficient token blacklist checking
  - Add database indexes for authentication-related queries
  - Write performance tests for authentication endpoints
  - _Requirements: 3.4, 3.5_

- [ ] 17. Documentation and final integration testing
  - Document new authentication API endpoints
  - Create developer documentation for authentication system
  - Write integration tests for complete authentication flows
  - Test compatibility with existing API key authentication
  - Verify multi-tenant isolation works correctly
  - Perform security review of implementation
  - _Requirements: 6.6, 8.8, 8.9_