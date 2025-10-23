describe('Flutter Web App - Basic Functionality', () => {
  beforeEach(() => {
    cy.visit('/', { timeout: 60000 })
    cy.waitForFlutter()
  })

  it('should load the app successfully', () => {
    cy.get('body').should('be.visible')
    cy.get('body').should('not.be.empty')
  })

  it.skip('should display the app title in the app bar', () => {
    // Skipped: Firebase UI renders inside Flutter canvas
    // App bar title is not accessible as HTML text
    cy.contains('Sign In').should('be.visible')
  })

  it.skip('should show the sign in screen when not authenticated', () => {
    // Skipped: Firebase UI renders inside Flutter canvas
    // Auth text is not accessible as HTML text
    cy.contains('Welcome to Cleteci Cross Platform, please sign in!').should('be.visible')
  })

  it.skip('should display the logo', () => {
    // Skipped: SVG logo renders inside Flutter canvas
    // Not accessible as HTML SVG element
    cy.get('svg').should('exist')
  })
})