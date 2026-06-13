# Contributing to Wakeon

Thank you for considering contributing to Wakeon.

Wakeon is a simple, privacy-first, open-source Wake-on-LAN application built with Flutter. The goal of the project is to provide a modern, reliable, and easy-to-use Wake-on-LAN experience without ads, tracking, user accounts, or unnecessary complexity.

## Code of Conduct

Please be respectful and constructive when interacting with other contributors.

We welcome:

- Bug reports
- Feature suggestions
- Documentation improvements
- Localization improvements
- Code contributions

## Before You Start

Before opening an issue or pull request:

- Check existing issues and discussions.
- Verify that the problem still exists on the latest version.
- Keep feature requests aligned with the project's privacy-first philosophy.

## Development Setup

Clone the repository and install dependencies:

```bash
git clone <repository-url>
cd wakeon
flutter pub get
```

Verify your environment:

```bash
flutter doctor
```

Run the application:

```bash
flutter run
```

## Quality Checks

Before submitting a pull request, make sure all checks pass:

```bash
dart format .
flutter analyze
flutter test
```

## Pull Request Guidelines

Please ensure that:

- The application builds successfully.
- New code follows the existing architecture and coding style.
- Public-facing text supports localization.
- Changes are tested when applicable.
- Documentation is updated when needed.
- Pull requests focus on a single topic whenever possible.

## Bug Reports

When reporting bugs, include:

- Device model
- Operating system version
- Wakeon version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots or logs when available

## Feature Requests

Feature requests should explain:

- The problem being solved
- The proposed solution
- Why it benefits users
- Any potential drawbacks

## Project Scope

Wakeon intentionally stays focused on Wake-on-LAN functionality.

Features generally considered out of scope include:

- User accounts
- Cloud synchronization
- Analytics and tracking
- Advertising SDKs
- Unrelated networking tools

## Localization

Wakeon currently supports Turkish and English.

Translation improvements are always welcome.

## Security

If you discover a security issue, please avoid creating a public issue.

Instead, contact the maintainer directly so the issue can be reviewed and fixed responsibly.

## License

By contributing to Wakeon, you agree that your contributions will be licensed under the same license as the project.