const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    baseUrl: 'http://localhost:8081', // Adjust based on your Flutter web app port
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    supportFile: 'cypress/support/e2e.js',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: false, // Disable video recording for local development
    screenshotOnRunFailure: true,
    defaultCommandTimeout: 20000,
    requestTimeout: 30000,
    responseTimeout: 30000,
    chromeWebSecurity: false, // Allow cross-origin requests
    env: {
      // Firebase Auth Emulator URL (commented out when using real Firebase)
      FIREBASE_AUTH_EMULATOR_URL: 'http://localhost:4000/auth',
      // Test user credentials
      TEST_USER_EMAIL: 'test@example.com',
      TEST_USER_PASSWORD: 'testpassword123'
    },
    setupNodeEvents(on, config) {
      // implement node event listeners here
      on('before:browser:launch', (browser, launchOptions) => {
        // Disable sandbox for Linux environments
        if (browser.family === 'chromium' && browser.name !== 'electron') {
          launchOptions.args.push('--disable-dev-shm-usage')
          launchOptions.args.push('--disable-gpu')
          launchOptions.args.push('--no-first-run')
          launchOptions.args.push('--disable-background-timer-throttling')
          launchOptions.args.push('--disable-backgrounding-occluded-windows')
          launchOptions.args.push('--disable-renderer-backgrounding')
          // Remove problematic flags for newer Cypress versions
          // launchOptions.args.push('--disable-web-security')
          // launchOptions.args.push('--allow-running-insecure-content')
        }
        return launchOptions
      })

      // Note: uncaught:exception is not a valid event in setupNodeEvents
      // Instead, we handle this in the support file
    },
  },
  retries: {
    runMode: 2,
    openMode: 0,
  },
})