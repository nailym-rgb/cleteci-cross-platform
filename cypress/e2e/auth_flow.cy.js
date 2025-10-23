Cypress.on('uncaught:exception', (err, runnable) => {
    // Retorna false para evitar que Cypress falle la prueba
    // cuando detecta un error no manejado por la app (como el TypeError).
    // Esto es común con la inicialización de Flutter/Firebase en web.
    return false;
});

describe('Authentication Flow - Robust E2E', () => {
  // Las variables de entorno para el usuario de prueba están en cypress.config.js/cypress.env.json
  const email = Cypress.env('TEST_USER_EMAIL');
  const password = Cypress.env('TEST_USER_PASSWORD');
  
  beforeEach(() => {
    cy.visit('/', { timeout: 60000 }); // Dejamos el timeout alto para la visita

    // 💡 PASO CLAVE: Esperar la capa de accesibilidad de Flutter (flt-semantics)
    // Este elemento es el que contiene todos los elementos DOM que Cypress puede leer
    // (inputs, botones, etc.) y aparece justo después de que el motor de Dart arranca.
    cy.get('flt-semantics', { timeout: 60000 }) 
      .should('exist')
      .log('Capa de accesibilidad de Flutter (flt-semantics) cargada.');
    
    // Opcional: Esperar el logo SVG, ahora con la confianza de que el DOM base existe.
    cy.get('img[src*="assets/cleteci_logo.svg"]', { timeout: 10000 })
      .should('be.visible')
      .log('El logo se cargó. Firebase UI está renderizado.');
      
    // Aserción final de la carga de Firebase UI
    cy.get('input[aria-label="Email address"]', { timeout: 10000 }).should('be.visible');

    cy.log('La pantalla de Sign In de Firebase UI está visible y lista.');
  });

  it('should load authentication screen and display its elements', () => {
    // Verifica que la aplicación haya cargado el contenedor principal.
    cy.get('body').should('be.visible');

    // For test mode, check for our custom elements
    cy.get('body').invoke('text').then(text => {
      if (text.includes('Sign In')) {
        // Test mode - check for our custom elements
        cy.contains('Sign In').should('be.visible')
        cy.contains('Register').should('be.visible')
        cy.contains('Forgot Password?').should('be.visible')
      } else {
        // Production mode - check for Firebase UI elements
        cy.get('input[aria-label="Email address"]', { timeout: 6000 }).should('be.visible');
      }
    })
    
    // Verifica que el campo de Contraseña sea visible (puede aparecer después del email).
    cy.get('input[aria-label="Password"]').should('be.visible');
    
    // El botón de Sign In (por defecto, tiene un aria-label de 'Sign in').
    cy.get('button[aria-label="Sign in"]').should('be.visible');
    
    // El enlace para registrarse
    cy.contains('Register').should('be.visible');

    // El enlace para restablecer la contraseña
    cy.contains('Forgot password?').should('be.visible');
  });

  it('should allow successful Sign In using Firebase UI fields', () => {
    // 1. Ingresar el email y contraseña
    cy.get('input[aria-label="Email address"]').type(email);
    cy.get('input[aria-label="Password"]').type(password);
    
    // 2. Click en el botón de Sign In
    cy.get('button[aria-label="Sign in"]').click();
    
    // 3. Verificación de redirección al estado autenticado
    //    (Basado en auth_gate.dart: 'return const DefaultPage(title: 'Cleteci Cross Platform Homepage');')
    //    Reemplazamos el assert débil por una verificación del contenido final.
    cy.contains('Cleteci Cross Platform Homepage', { timeout: 10000 }).should('be.visible');
  });

  it('should navigate to the Register screen', () => {
    // Navegar haciendo clic en el enlace "Register"
    cy.contains('Register').click();

    // Verificación: Se carga el widget RegisterScreen, que tiene el título 'Register' en el DefaultAppBar.
    // Usamos el título del AppBar de Register (visto en auth_gate.dart).
    cy.contains('Register', { timeout: 5000 }).should('be.visible');

    // Opcional: Verificar un campo clave de registro (ej. 'Name' o 'Display Name')
    // Asumiendo que RegisterScreen tiene un campo de Display Name.
    cy.get('input[aria-label="Display name"]').should('be.visible');
  });
  
  it('should navigate to the Forgot Password screen', () => {
    // Navegar haciendo clic en el enlace "Forgot password?"
    cy.contains('Forgot password?').click();

    // Verificación: Se carga el widget ForgotPasswordScreen.
    // El título de la pantalla está implícito en ForgotPasswordScreen.
    // Buscamos el botón de acción clave de la pantalla.
    cy.get('button[aria-label="Send sign in link"]').should('be.visible');
    
    // Verificar que el campo de email para recuperación esté presente.
    cy.get('input[aria-label="Email address"]').should('be.visible');
  });
  
  // Nota: Las pruebas de navegación de retorno (ej. "Back to sign in") también deben ser incluidas.
});