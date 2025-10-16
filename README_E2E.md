# E2E Testing Setup with Cypress

This document explains how to set up and run End-to-End (E2E) tests for the Flutter web application using Cypress.

## Prerequisites

- Node.js 18+ and npm
- Flutter SDK
- The Flutter web app built and ready

### Installing Node.js (if not installed)

```bash
# Using the script added to pubspec.yaml
flutter pub run pubspec install:node

# Or manually:
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

## Amplify Deployment

The E2E tests are automatically integrated into your Amplify deployment pipeline. The `amplify.yml` configuration includes:

1. **preBuild**: Installs Flutter SDK and Node.js
2. **build**: Compiles the Flutter web app
3. **test**: Runs E2E tests before deployment
4. **artifacts**: Deploys the built app

### E2E Tests in Amplify

- Tests run automatically on every deployment
- Uses headless Chrome browser
- No video recording to avoid timeouts
- Tests must pass for deployment to succeed
- Results are available in Amplify build logs

## Installation

1. Install Node.js dependencies:
   ```bash
   npm install
   ```

2. Build the Flutter web app:
   ```bash
   flutter pub get
   flutter build web --release --pwa-strategy none
   ```

## Running Tests

### Local Development

1. Start the Flutter web server:
   ```bash
   flutter pub global activate dhttpd
   flutter pub global run dhttpd --path build/web --port 8080
   ```

2. In another terminal, run Cypress tests:
   ```bash
   npm run cy:open  # Opens Cypress Test Runner (interactive)
   # or
   npm run cy:run   # Runs tests headlessly
   ```

### Using Scripts

The project includes convenient scripts in `pubspec.yaml`:

```bash
# Setup everything for E2E testing
flutter pub run pubspec test:e2e:setup

# Run E2E tests (assumes server is running)
flutter pub run pubspec test:e2e
```

## Test Structure

```
cypress/
├── e2e/
│   ├── app_load.cy.js      # Basic app loading tests
│   ├── auth_flow.cy.js     # Authentication flow tests
│   └── navigation.cy.js    # Navigation and routing tests
├── support/
│   ├── commands.js         # Custom Cypress commands
│   └── e2e.js             # Global test configuration
└── fixtures/               # Test data fixtures
```

## Custom Commands

The following custom commands are available in `cypress/support/commands.js`:

- `cy.login(email, password)` - Login with credentials
- `cy.logout()` - Logout user
- `cy.waitForFlutter()` - Wait for Flutter app to load
- `cy.loginWithGoogle()` - Handle Google OAuth login

## Configuration

- **Base URL**: `http://localhost:8080` (configured in `cypress.config.js`)
- **Viewport**: 1280x720 (desktop testing)
- **Timeouts**: 10s default, 15s request, 15s response
- **Retries**: 2 runs, 0 open mode

## CI/CD Integration

E2E tests are automatically run in GitHub Actions on pushes to `master` and `develop` branches after unit tests pass. The workflow:

1. Builds the Flutter web app
2. Starts a local server
3. Installs Cypress dependencies
4. Runs E2E tests
5. Uploads test artifacts (videos/screenshots) on failure

## Writing New Tests

1. Create new test files in `cypress/e2e/` with `.cy.js` extension
2. Use data-cy attributes for element selection in your Flutter widgets
3. Leverage custom commands for common actions
4. Follow the Page Object Model pattern for complex tests

Example test structure:
```javascript
describe('Feature Name', () => {
  beforeEach(() => {
    cy.waitForFlutter()
    // Setup code
  })

  it('should do something', () => {
    // Test code
  })
})
```

## Troubleshooting

- **Server not starting**: Ensure port 8080 is available
- **Tests timing out**: Increase timeouts in `cypress.config.js`
- **Elements not found**: Add `data-cy` attributes to Flutter widgets
- **CORS issues**: Configure proper headers in the web server

## Best Practices

- Use descriptive test names
- Keep tests independent and isolated
- Use custom commands for reusable actions
- Add proper waiting mechanisms for async operations
- Test both positive and negative scenarios
- Keep test data separate from test logic