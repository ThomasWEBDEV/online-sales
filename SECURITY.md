# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability, please send an email to thomas.feret@hotmail.fr

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will respond within 48 hours.

## Security Measures

This application implements multiple security layers:

### Authentication & Authorization
- Devise with session timeout (30 min)
- Pundit for authorization
- Honeypot anti-bot on registration
- Rate limiting on login attempts (4 attempts/20s)

### Data Protection
- HTTPS enforced (force_ssl)
- Secure cookies (httponly, secure, samesite)
- CSRF protection enabled
- Content Security Policy (CSP)
- DNS rebinding protection

### Input Validation
- Strong parameters
- File upload validation (size, type)
- Email format validation
- Phone format validation
- Database-level constraints (NOT NULL, CHECK)

### API Security
- Stripe webhook signature verification
- Timeout configuration (10s open, 30s read)
- Rate limiting on webhooks

### Monitoring & Logging
- Audit logging for sensitive actions
- Failed login tracking
- Security parameter filtering in logs
- Brakeman security scanner

### Infrastructure
- Database indexes for performance
- Open redirect protection
- Mass assignment protection

## Dependencies

We regularly update dependencies to patch security vulnerabilities.
Run `bundle exec brakeman` to scan for known vulnerabilities.

## Supported Versions

Only the latest version receives security updates.
