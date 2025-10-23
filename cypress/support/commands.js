// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************

/// <reference types="cypress" />

// Custom command to login via Firebase Auth
Cypress.Commands.add('login', (email, password) => {
  cy.visit('/')
  // Assuming your app has a login form
  cy.get('[data-cy="email-input"]').type(email)
  cy.get('[data-cy="password-input"]').type(password)
  cy.get('[data-cy="login-button"]').click()
  // Wait for login to complete
  cy.url().should('not.include', '/login')
})

// Custom command to logout
Cypress.Commands.add('logout', () => {
  cy.get('[data-cy="logout-button"]').click()
  cy.url().should('include', '/login')
})

// Custom command to wait for Flutter app to load
Cypress.Commands.add('waitForFlutter', () => {
  // First, wait for the basic HTML to load
  cy.get('body', { timeout: 30000 }).should('not.be.empty')

  // Wait for Flutter app to be ready - check for main Flutter elements
  cy.get('body', { timeout: 30000 }).should('contain', 'flutter')

  // Wait for Firebase initialization and auth state - increased wait time
  cy.wait(15000) // Give Flutter and Firebase even more time to initialize

  // Check that the app has loaded by looking for common elements
  cy.get('body').should('be.visible')

  // Additional wait to ensure Flutter has fully rendered
  cy.wait(5000)
})

// Custom command for Google OAuth login (if applicable)
Cypress.Commands.add('loginWithGoogle', () => {
  cy.visit('/')
  cy.get('[data-cy="google-signin-button"]').click()
  // Handle OAuth popup if needed
  cy.window().then((win) => {
    // Mock or handle OAuth flow
  })
})

// Custom command to login with email and password
Cypress.Commands.add('login', (email, password) => {
  // Wait for form to be ready
  cy.get('input[type="email"]', { timeout: 10000 }).should('be.visible')
  cy.get('input[type="password"]', { timeout: 10000 }).should('be.visible')

  // Clear and type credentials
  cy.get('input[type="email"]').clear().type(email)
  cy.get('input[type="password"]').clear().type(password)

  // Click sign in button
  cy.contains('Sign in').should('be.visible').click()

  // Wait for potential navigation or error
  cy.wait(3000)
})

// Custom command to logout
Cypress.Commands.add('logout', () => {
  // Click user profile button in app bar
  cy.get('[data-cy="profile-button"]').click()
  // Click sign out button
  cy.contains('Sign out').click()
})