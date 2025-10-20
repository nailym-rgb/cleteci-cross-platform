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

2. Construir la aplicación Flutter web:
   ```bash
   flutter pub get
   flutter build web --release --pwa-strategy none
   ```

### Windows
1. Instalar dependencias de Node.js:
   ```powershell
   npm install
   ```

2. Construir la aplicación Flutter web:
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

El proyecto incluye scripts convenientes en `pubspec.yaml`:

#### Linux/macOS
```bash
# Configurar todo para pruebas E2E
flutter pub run pubspec test:e2e:setup

# Ejecutar pruebas E2E (asume que el servidor está corriendo)
flutter pub run pubspec test:e2e
```

#### Windows
```powershell
# Configurar todo para pruebas E2E
flutter pub run pubspec test:e2e:setup

# Ejecutar pruebas E2E (asume que el servidor está corriendo)
flutter pub run pubspec test:e2e
```

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

- `cy.login(email, password)` - Iniciar sesión con credenciales
- `cy.logout()` - Cerrar sesión del usuario
- `cy.waitForFlutter()` - Esperar a que la app Flutter cargue
- `cy.loginWithGoogle()` - Manejar login OAuth de Google

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

## Mejores Prácticas

- Usar nombres descriptivos para las pruebas
- Mantener pruebas independientes y aisladas
- Usar comandos personalizados para acciones reutilizables
- Agregar mecanismos de espera apropiados para operaciones asíncronas
- Probar escenarios positivos y negativos
- Mantener datos de prueba separados de la lógica de pruebas