# Configuración de Pruebas E2E con Cypress

Este documento explica cómo configurar y ejecutar pruebas End-to-End (E2E) para la aplicación web Flutter usando Cypress.

## Prerrequisitos

- Node.js 18+ y npm
- Flutter SDK
- La aplicación Flutter web compilada y lista

### Instalando Node.js (si no está instalado)

#### Linux (Ubuntu/Debian)
```bash
# Usando el script agregado al pubspec.yaml
flutter pub run pubspec install:node

# O manualmente:
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar instalación
node --version
npm --version
```

#### macOS
```bash
# Usando Homebrew (recomendado)
brew install node

# O descargar el instalador desde https://nodejs.org/

# Verificar instalación
node --version
npm --version
```

#### Windows
```powershell
# Usando Chocolatey (recomendado)
choco install nodejs

# O descargar el instalador MSI desde https://nodejs.org/

# Verificar instalación
node --version
npm --version
```

### Instalando Flutter SDK

#### Linux
```bash
# Descargar Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
tar xf flutter_linux_3.24.0-stable.tar.xz

# Agregar Flutter al PATH (agregar a ~/.bashrc o ~/.zshrc)
export PATH="$PATH:`pwd`/flutter/bin"

# Verificar instalación
flutter --version
flutter doctor
```

#### macOS
```bash
# Usando Homebrew
brew install --cask flutter

# O descargar desde https://flutter.dev/docs/get-started/install/macos

# Verificar instalación
flutter --version
flutter doctor
```

#### Windows
```powershell
# Descargar Flutter SDK desde https://flutter.dev/docs/get-started/install/windows
# Extraer en C:\flutter

# Agregar Flutter al PATH del sistema
# Verificar instalación
flutter --version
flutter doctor
```

## Despliegue en Amplify

Las pruebas E2E están integradas automáticamente en el pipeline de despliegue de Amplify. La configuración `amplify.yml` incluye:

1. **preBuild**: Instala Flutter SDK y Node.js
2. **build**: Compila la aplicación Flutter web
3. **test**: Ejecuta pruebas E2E antes del despliegue
4. **artifacts**: Despliega la aplicación compilada

### Pruebas E2E en Amplify

- Las pruebas se ejecutan automáticamente en cada despliegue
- Usa navegador Chrome headless
- Sin grabación de video para evitar timeouts
- Las pruebas deben pasar para que el despliegue sea exitoso
- Los resultados están disponibles en los logs de build de Amplify

## Instalación

### Linux/macOS
1. Instalar dependencias de Node.js:
   ```bash
   npm install
   ```

2. Configurar variables de entorno para pruebas (opcional):
   ```bash
   cp cypress.env.example cypress.env.json
   # Editar cypress.env.json con tus credenciales de prueba
   ```

3. Construir la aplicación Flutter web:
   ```bash
   flutter pub get
   flutter build web --release --pwa-strategy none
   ```

### Windows
1. Instalar dependencias de Node.js:
   ```powershell
   npm install
   ```

2. Configurar variables de entorno para pruebas (opcional):
   ```powershell
   copy cypress.env.example cypress.env.json
   # Editar cypress.env.json con tus credenciales de prueba
   ```

3. Construir la aplicación Flutter web:
   ```powershell
   flutter pub get
   flutter build web --release --pwa-strategy none
   ```

## Ejecutando Pruebas

### Desarrollo Local

#### Linux/macOS
1. Iniciar el servidor web Flutter:
   ```bash
   flutter pub global activate dhttpd
   flutter pub global run dhttpd --path build/web --port 8080
   ```

2. En otra terminal, ejecutar pruebas Cypress:
   ```bash
   npm run cy:open  # Abre Cypress Test Runner (interactivo)
   # o
   npm run cy:run   # Ejecuta pruebas sin interfaz
   ```

#### Windows
1. Iniciar el servidor web Flutter:
   ```powershell
   flutter pub global activate dhttpd
   flutter pub global run dhttpd --path build/web --port 8080
   ```

2. En otra terminal, ejecutar pruebas Cypress:
   ```powershell
   npm run cy:open  # Abre Cypress Test Runner (interactivo)
   # o
   npm run cy:run   # Ejecuta pruebas sin interfaz
   ```

### Usando Scripts

El proyecto incluye scripts convenientes en `package.json` y `pubspec.yaml`:

#### Scripts de package.json (recomendados - verifican servidor automáticamente)

```bash
# Construir la aplicación web
npm run build-web

# Verificar/iniciar servidor y ejecutar pruebas específicas
npm run test:e2e:auth        # Pruebas de autenticación (headless)
npm run test:e2e:auth:headed # Pruebas de autenticación (con navegador)
npm run test:e2e:app         # Pruebas de carga de app (headless)
npm run test:e2e:app:headed  # Pruebas de carga de app (con navegador)
npm run test:e2e:nav         # Pruebas de navegación (headless)
npm run test:e2e:nav:headed  # Pruebas de navegación (con navegador)

# Ejecutar todas las pruebas
npm run test:e2e             # Todas las pruebas (headless)
npm run test:e2e:headed      # Todas las pruebas (con navegador)
```

#### Scripts de pubspec.yaml (alternativos)

##### Linux/macOS
```bash
# Configurar todo para pruebas E2E
flutter pub run pubspec test:e2e:setup

# Ejecutar pruebas E2E (asume que el servidor está corriendo)
flutter pub run pubspec test:e2e
```

##### Windows
```powershell
# Configurar todo para pruebas E2E
flutter pub run pubspec test:e2e:setup

# Ejecutar pruebas E2E (asume que el servidor está corriendo)
flutter pub run pubspec test:e2e
```

### Configuración de Autenticación con Firebase

Para probar el sign in con credenciales reales o emulador:

#### Opción 1: Firebase Auth Emulator (Recomendado para desarrollo)

1. **Instalar Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

2. **Configurar proyecto Firebase** (si no tienes uno):
   ```bash
   firebase init
   # Seleccionar "Authentication" y configurar proyecto
   ```

3. **Iniciar Auth Emulator**:
   ```bash
   firebase emulators:start --only auth
   ```

4. **Crear usuario de prueba**:
   ```bash
   curl -X POST http://localhost:9099/identitytoolkit.googleapis.com/v1/accounts:signUp?key=any-key \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"testpassword123"}'
   ```

5. **Configurar Cypress**:
   - Asegúrate de que `FIREBASE_AUTH_EMULATOR_URL` esté configurado en `cypress.config.js`
   - Las credenciales de prueba ya están configuradas

#### Opción 2: Usuario Real en Firebase

1. **Crear usuario en Firebase Console**:
   - Ve a Firebase Console → Authentication → Users
   - Click "Add user"
   - Email: `test@example.com`
   - Password: `testpassword123`

2. **Configurar Cypress**:
   - Comenta la línea `FIREBASE_AUTH_EMULATOR_URL` en `cypress.config.js`
   - Asegúrate de que las credenciales en `cypress.env.json` sean correctas

#### Opción 3: Autenticación Mockeada (Avanzado)

Para testing avanzado, puedes crear un sistema de mocking:

1. **Crear endpoint de mock** en tu aplicación Flutter
2. **Configurar Cypress** para interceptar llamadas de autenticación
3. **Simular respuestas** de Firebase Auth

#### Ejecutar Pruebas de Autenticación

```bash
# Con Firebase Emulator
firebase emulators:start --only auth &
npm run test:e2e:auth:headed

# Con usuario real
npm run test:e2e:auth:headed
```

#### Notas Importantes

- **Firebase UI en Flutter Canvas**: Los elementos de Firebase UI se renderizan dentro del canvas de Flutter, lo que hace imposible la interacción directa con Cypress
- **Testing de Autenticación**: Requiere configuración adicional (emulador o mocking)
- **Alternativas**: Considera usar Flutter Integration Tests para testing de autenticación completo

## Estructura de Pruebas

```
cypress/
├── e2e/
│   ├── app_load.cy.js      # Pruebas básicas de carga de app
│   ├── auth_flow.cy.js     # Pruebas de flujo de autenticación
│   └── navigation.cy.js    # Pruebas de navegación y rutas
├── support/
│   ├── commands.js         # Comandos personalizados de Cypress
│   └── e2e.js             # Configuración global de pruebas
└── fixtures/               # Datos de prueba
```

## Comandos Personalizados

Los siguientes comandos personalizados están disponibles en `cypress/support/commands.js`:

- `cy.login(email, password)` - Iniciar sesión con credenciales de email/contraseña
- `cy.logout()` - Cerrar sesión del usuario
- `cy.waitForFlutter()` - Esperar a que la app Flutter cargue completamente
- `cy.loginWithGoogle()` - Manejar login OAuth de Google (requiere configuración adicional)

## Configuración

- **URL Base**: `http://localhost:8080` (configurado en `cypress.config.js`)
- **Viewport**: 1280x720 (pruebas de escritorio)
- **Timeouts**: 10s por defecto, 15s para requests, 15s para responses
- **Reintentos**: 2 para modo ejecución, 0 para modo abierto

## Integración CI/CD

Las pruebas E2E se ejecutan automáticamente en GitHub Actions en pushes a las ramas `master` y `develop` después de que pasan las pruebas unitarias. El workflow:

1. Construye la aplicación Flutter web
2. Inicia un servidor local
3. Instala dependencias de Cypress
4. Ejecuta pruebas E2E
5. Sube artifacts de pruebas (videos/screenshots) en caso de fallo

## Escribiendo Nuevas Pruebas

1. Crear nuevos archivos de prueba en `cypress/e2e/` con extensión `.cy.js`
2. Usar atributos `data-cy` para selección de elementos en tus widgets Flutter
3. Aprovechar comandos personalizados para acciones comunes
4. Seguir el patrón Page Object Model para pruebas complejas

Ejemplo de estructura de prueba:
```javascript
describe('Nombre de Característica', () => {
  beforeEach(() => {
    cy.waitForFlutter()
    // Código de configuración
  })

  it('debería hacer algo', () => {
    // Código de prueba
  })
})
```

## Solución de Problemas

- **Servidor no inicia**: Asegurarse de que el puerto 8080 esté disponible
- **Pruebas con timeout**: Aumentar timeouts en `cypress.config.js`
- **Elementos no encontrados**: Agregar atributos `data-cy` a widgets Flutter
- **Problemas de CORS**: Configurar headers apropiados en el servidor web
- **Errores de autenticación**: Las pruebas de login requieren configuración de Firebase (emulador o credenciales de prueba)
- **Flutter no carga**: Verificar que `flutter build web` se ejecutó correctamente y que el servidor está sirviendo los archivos

## Mejores Prácticas

- Usar nombres descriptivos para las pruebas
- Mantener pruebas independientes y aisladas
- Usar comandos personalizados para acciones reutilizables
- Agregar mecanismos de espera apropiados para operaciones asíncronas
- Probar escenarios positivos y negativos
- Mantener datos de prueba separados de la lógica de pruebas