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

Para ver el proyecto, vamos al siguiente URL: [http://localhost:8080/](http://localhost:8080/).