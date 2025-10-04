# cross-platform

Aplicación Cross Platform con código único base (Web, Android, iOS)

## Requisitos.

- [VSCode](https://code.visualstudio.com/).
- [Flutter](https://flutter.dev/).
- [Android Studio](https://developer.android.com/studio).

## Setup.

- Seguir la Guía de [Quickstart de Flutter](https://docs.flutter.dev/get-started/quick).
- Seguir la Guía de [Android Setup](https://docs.flutter.dev/platform-integration/android/setup).

## Ejecución del Proyecto.

En la Guía de [Quickstart de Flutter](https://docs.flutter.dev/get-started/quick) se encuentra cómo ejecutar el proyecto de Flutter en el navegador (Chrome; se inicia una ventana automáticamente). Para ejecutarlo en dispositivos Android, por ejemplo, se siguen los mismos pasos pero cambiando el dispositivo para ejecución del proyecto, como se muestra en la siguiente imagen:

![Selección de Dispositivo en VS Code](select-device.png)

### Ejecución de Proyecto Web con Docker.

Ejecutamos el siguiente comando para hacer *build* del contenedor de Docker:

```
docker-compose up --build -d
```

Debemos ver el siguiente mensaje indicando que se creó el contenedor:

![Contenedor Creado por Consola](created-container.png)

En Docker Desktop, podremos ver lo siguiente:

![Contenedor en Ejecución en Docker Desktop](docker-desktop-running-container.png)

## Pipeline de CI/CD

Este proyecto utiliza GitHub Actions para la integración y el despliegue continuos.

### Desencadenantes del flujo de trabajo

La canalización de integración continua (CI) se ejecuta en:
- Envíos a las ramas principal, maestra, de desarrollo y de características
- Solicitudes de extracción dirigidas a estas ramas

### Job

- **test**: Configura Flutter, instala dependencias, ejecuta pruebas y compila la aplicación web
- **build-docker**: Compila la imagen de Docker (solo en envíos a las ramas maestra o de desarrollo)

### Integración con Docker Hub

Para habilitar los envíos automáticos de Docker Hub:
1. Crea una cuenta de Docker Hub en https://hub.docker.com/
2. Genera un token de acceso en Configuración de la cuenta > Seguridad
3. Agrega `DOCKER_USERNAME` y `DOCKER_PASSWORD` como secretos del repositorio en GitHub
4. Descomenta los pasos de Docker Hub en `.github/workflows/ci.yml`
Para ver el proyecto, vamos a la siguiente URL: [http://localhost:8080/](http://localhost:8080/).