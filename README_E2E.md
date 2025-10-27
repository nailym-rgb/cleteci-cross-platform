# Pruebas de Integración

Este documento explica cómo configurar y ejecutar pruebas de integración para la aplicación Flutter usando Flutter Integration Tests.

## Información General

Las pruebas de integración se ejecutan directamente en la aplicación Flutter, probando la funcionalidad completa desde la perspectiva del usuario. Estas pruebas son más confiables que las pruebas E2E externas ya que no dependen de frameworks adicionales como Cypress.

## Requisitos

- Flutter SDK instalado
- Dispositivo/emulador/simulador configurado para testing

## Ejecutando Pruebas

### Pruebas de Integración

```bash
# Ejecutar todas las pruebas de integración
flutter test integration_test/

# Ejecutar pruebas específicas
flutter test integration_test/auth_flow_test.dart

# Ejecutar con reporte de cobertura
flutter test integration_test/ --coverage
```

### Pruebas Unitarias

```bash
# Ejecutar todas las pruebas unitarias
flutter test

# Ejecutar pruebas específicas
flutter test test/ui/auth/local_auth_state_test.dart

# Ejecutar con cobertura
flutter test --coverage
```

## Estructura de Pruebas

```
integration_test/
├── auth_flow_test.dart    # Pruebas de flujo de autenticación completo

test/
├── widget_test.dart       # Pruebas básicas de widgets
├── local_auth_state_test.dart
└── ui/
    └── auth/
        └── local_auth_state_test.dart  # Pruebas específicas de autenticación local
```

## Configuración CI/CD

Las pruebas se ejecutan automáticamente en GitHub Actions:

1. **Pruebas Unitarias**: Se ejecutan en cada push/PR
2. **Cobertura**: Se verifica mínimo 80% de cobertura
3. **Build**: Se compila la aplicación web
4. **Docker**: Se construye imagen para despliegue

## Escribiendo Nuevas Pruebas

### Pruebas de Integración

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('descripción de la prueba', (WidgetTester tester) async {
    // Configuración de la prueba
    // ...

    // Ejecutar acciones
    // ...

    // Verificar resultados
    expect(find.text('Texto esperado'), findsOneWidget);
  });
}
```

### Pruebas Unitarias

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('descripción de la prueba', () {
    // Arrange
    // ...

    // Act
    // ...

    // Assert
    expect(resultado, esperado);
  });
}
```

## Mejores Prácticas

- Mantener pruebas independientes y aisladas
- Usar nombres descriptivos
- Probar escenarios positivos y negativos
- Mantener buena cobertura de código
- Ejecutar pruebas regularmente durante desarrollo

## Solución de Problemas

- **Dispositivo no encontrado**: Asegurarse de tener un emulador/simulador corriendo
- **Dependencias faltantes**: Ejecutar `flutter pub get`
- **Timeouts**: Aumentar timeouts para operaciones asíncronas
- **Widgets no encontrados**: Verificar que los widgets estén correctamente renderizados

## Cobertura de Código

La cobertura se mide automáticamente en CI/CD. Para ver reportes localmente:

```bash
flutter test --coverage
# Los reportes estarán en coverage/lcov.info.
