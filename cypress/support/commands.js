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
  cy.get('body', { timeout: 30000 }).should('not.be.empty')
  // Wait for Flutter app to be ready - check for main Flutter elements
  cy.get('body', { timeout: 30000 }).should('contain', 'flutter')
  // Wait for the app to be interactive
  cy.wait(2000) // Give Flutter time to initialize
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