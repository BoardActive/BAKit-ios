# Changelog

All notable changes to BAKit-iOS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.1] - 2025-11-05

### Added
- Campaign tracking for geofences (internal analytics improvement)
- Enhanced logging for production debugging

### Fixed
- Improved production logging (removed verbose debug output for App Store submission)
- Backend API now returns all active geofences (campaign + non-campaign)

### Changed
- Cleaned up console output for production environments
- Simplified geofence monitoring logs while keeping essential error tracking

## [2.1.0] - Previous Release

### Features
- Location-based geofence monitoring
- Firebase Cloud Messaging integration
- Background location updates
- Rich notification support
- Campaign analytics tracking
