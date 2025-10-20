describe('Flutter Web App - Basic Functionality', () => {
  beforeEach(() => {
    cy.visit('/')
    cy.waitForFlutter()
  })

  it('should load the app successfully', () => {
    cy.get('body').should('be.visible')
    cy.get('body').should('not.be.empty')
  })

  it('should display the app title', () => {
    // Check for the app title that appears in the AuthGate
    cy.contains('Cleteci Cross Platform').should('be.visible')
  })

  it('should show the sign in screen when not authenticated', () => {
    // Check for Firebase UI Auth elements
    cy.contains('Welcome to Cleteci Cross Platform').should('be.visible')
    cy.contains('please sign in!').should('be.visible')
  })

  it('should display the logo', () => {
    // Check if the SVG logo is loaded
    cy.get('svg').should('be.visible')
  })
})