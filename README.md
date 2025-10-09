# cross-platform

Aplicación Cross Platform con código único base (Web, Android, iOS)

## Información General

Proyecto Flutter multiplataforma para Web, Android e iOS. Utiliza Firebase como backend y soporta despliegue en Docker y CI/CD con GitHub Actions.

## Requisitos Rápidos
- [VSCode](https://code.visualstudio.com/)
- [Flutter](https://flutter.dev/)
- [Android Studio](https://developer.android.com/studio)
- (Opcional) Docker

## Despliegue Rápido

1. Instala dependencias:
   ```pwsh
   flutter pub get
   ```
2. Ejecuta en Web:
   ```pwsh
   flutter run -d chrome
   ```
3. Ejecuta en Android:
   ```pwsh
   flutter run -d android
   ```
4. Ejecuta en iOS (solo macOS):
   ```pwsh
   flutter run -d ios
   ```
5. Despliegue con Docker:
   ```pwsh
   docker-compose up --build -d
   ```

## Documentación Detallada

Consulta la guía completa de compilación y despliegue en [`docs/builds_and_deploys.md`](docs/builds_and_deploys.md).

## CI/CD y Docker Hub

Este proyecto utiliza GitHub Actions para la integración y el despliegue continuo.

### Pipeline principal
- Ejecuta pruebas y compila la aplicación en cada push o pull request a ramas principales (`master`, `develop`, `feature/*`).
- Compila la imagen de Docker en ramas de desarrollo y producción.

### Integración con Docker Hub
1. Crea una cuenta en [Docker Hub](https://hub.docker.com/).
2. Genera un token de acceso en la configuración de tu cuenta.
3. Agrega los secretos `DOCKER_USERNAME` y `DOCKER_PASSWORD` en el repositorio de GitHub.
4. Descomenta los pasos de Docker Hub en `.github/workflows/ci.yml` para habilitar el push automático.

Para más detalles y pasos avanzados, consulta [`docs/builds_and_deploys.md`](docs/builds_and_deploys.md).