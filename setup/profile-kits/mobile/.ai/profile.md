# Project Profile: Mobile

This project uses the Mobile profile. Keep decisions grounded in platform conventions, device constraints, accessibility, offline/network behavior, and release safety.

## Product Areas To Notice

- Navigation, gestures, permissions, and platform-specific conventions
- Device sizes, safe areas, orientation, and keyboard behavior
- Offline, flaky network, retries, and sync conflict states
- Push notifications, deep links, app lifecycle, and background work
- Accessibility, localization, app store release, and crash monitoring

## Workflow Defaults

- Use `grill-with-context` before planning vague mobile flows or permissions-heavy features.
- Use `domain-modeling` for unclear lifecycle/status terms like draft, synced, pending, failed, offline, submitted, approved, or archived.
- Use `to-spec` and `to-tickets` for changes touching navigation, permissions, offline state, push notifications, or release behavior.
- Prefer slices that can be verified on the smallest meaningful set of devices or simulators.

## Review Gates

Ask for review before merging changes that affect:

- Authentication, permissions, secure storage, or privacy-sensitive data
- Offline sync, conflict resolution, or destructive local persistence
- Push notifications or deep links
- App release configuration, entitlements, or store metadata
- Accessibility for core workflows

## Design Bias

Mobile UI should follow platform conventions first. Verify important states on real device sizes, including keyboard, safe-area, loading, empty, error, and offline states.
