# Guía de Compilación y Despliegue

Este documento detalla el proceso para compilar y desplegar la aplicación en sus tres variantes: Web, Android e iOS. Está diseñado para ser claro, reproducible y actualizable en cada Sprint.

---

## Web

### Requisitos de entorno
- Flutter SDK instalado ([Guía oficial](https://docs.flutter.dev/get-started/install)).
- Docker (opcional, para despliegue en contenedor).
- Acceso a la terminal (PowerShell, Bash, etc).

### Instalación de dependencias
```pwsh
flutter pub get
```

### Compilación para Web
```pwsh
flutter build web --release
```
El resultado estará en la carpeta `build/web`.

### Despliegue local
```pwsh
flutter run -d chrome
```

### Despliegue con Docker
```pwsh
docker-compose up --build -d
```
Accede a [http://localhost:8080/](http://localhost:8080/) para ver la app.

### Consideraciones por entorno
- **Staging:** Usar variables de entorno y endpoints de prueba.
- **Producción:** Validar configuración de dominios, CDN y credenciales.

---

## Android

### Requisitos de entorno
- Flutter SDK instalado ([Guía oficial](https://docs.flutter.dev/get-started/install)).
- Android Studio instalado y configurado ([Guía oficial](https://docs.flutter.dev/platform-integration/android/setup)).
- Emulador Android o dispositivo físico conectado.

### Instalación de dependencias
```pwsh
flutter pub get
```

### Compilación para Android
```pwsh
flutter build apk --release
```
El archivo APK se genera en `build/app/outputs/flutter-apk/app-release.apk`.

### Ejecución en dispositivo/emulador
```pwsh
flutter run -d android
```

### Consideraciones por entorno
- **Staging:** Configurar endpoints y credenciales de prueba en archivos de entorno.
- **Producción:** Verificar configuración de firma, versión y credenciales.

---

## iOS

### Requisitos de entorno
- Flutter SDK instalado ([Guía oficial](https://docs.flutter.dev/get-started/install)).
- Xcode instalado y configurado (solo en macOS).
- Dispositivo físico o simulador iOS.

### Instalación de dependencias
```pwsh
flutter pub get
```

### Compilación para iOS
```pwsh
flutter build ios --release
```
El resultado estará en la carpeta `build/ios/iphoneos`.

### Ejecución en simulador/dispositivo
```pwsh
flutter run -d ios
```

### Despliegue en App Store
1. Abrir el proyecto en Xcode: `ios/Runner.xcworkspace`.
2. Configurar los detalles del paquete en Xcode.
3. Archivar y subir a la App Store desde Xcode.

### Consideraciones por entorno
- **Staging:** Usar configuraciones de prueba en archivos de entorno y provisioning profiles de desarrollo.
- **Producción:** Verificar certificados, provisioning profiles y configuración de App Store.

---