# Estrategia de Testing - Cleteci Cross Platform

Este documento describe los diferentes niveles de pruebas implementados en el proyecto y cómo ejecutarlos localmente y en el pipeline de CI/CD.

## 1. Pruebas Unitarias y de Widget
Ubicadas en la carpeta `test/`. Estas pruebas verifican la lógica de negocio y los componentes de la UI de forma aislada.

**Para ejecutar todas las pruebas unitarias:**
```pwsh
flutter test
```
## 2. Pruebas de Integración (E2E)
Ubicadas en la carpeta integration_test/. Estas pruebas verifican el flujo completo de la aplicación en un dispositivo real o emulador.

Para ejecutar pruebas de integración:
- Asegúrate de tener un emulador iniciado o un dispositivo conectado.

**Ejecuta el comando:**
```pwsh
flutter test integration_test/app_test.dart
```

## 3. Análisis Estático
Utilizamos analysis_options.yaml para mantener la calidad del código y seguir las mejores prácticas de Dart/Flutter.

**Ejecuta el comando:**
```pwsh
flutter analyze
```

## 4. Cobertura de Código
Para generar un reporte de cobertura de las pruebas:
```pwsh
flutter test --coverage
# Para visualizar el reporte (requiere lcov instalado)
genhtml coverage/lcov.info -o coverage/html
```

## 5. Integración Continua (CI)
El archivo .github/workflows/ci.yml ejecuta automáticamente las pruebas en cada push o pull request hacia las ramas master, develop o feature/*.

**Pasos del Pipeline:**

- Análisis de código (flutter analyze).
- Ejecución de pruebas unitarias (flutter test).
- Verificación de formato.



