# Arquitectura de Software - Portal de Clientes Cross-Platform (Flutter)

## 1. Introducción

### 1.1. Propósito

Este documento provee una explicación detallada de la arquitectura de software seleccionada para la plataforma. El objetivo es servir como una **fuente de referencia única, clara y precisa** para desarrolladores, QA y DevOps, garantizando la **alineación técnica** en el desarrollo de la solución Cross-Platform.

[cite_start]El propósito central es definir una arquitectura que permita la **separación de la lógica de negocio** (Firebase) de la **lógica de diseño** (Flutter)[cite: 13].

### 1.2. Alcance

[cite_start]El alcance de este documento cubre el diseño de la **solución web y móvil** para la gestión de clientes, proyectos, presupuestos y documentos (similares a los requisitos del documento de referencia [cite: 18, 20]).

El enfoque arquitectónico abarca el **Stack Tecnológico**, el **Diseño Lógico de Capas** (N-Capas con cliente Cross-Platform), la **Estrategia de CI/CD (DevOps)** y los **Requisitos No Funcionales** de la plataforma.

[cite_start]El acompañamiento en la adopción de **mejores prácticas metodológicas** (como el manejo de repositorios y QA) también está implícito en la definición de CI/CD[cite: 19].

---

## 2. Definición de la Arquitectura

### 2.1. Arquitectura Lógica de Capas (N-Capas)

La arquitectura seleccionada comprende un modelo de **N-Capas con Cliente Cross-Platform**, sustituyendo el cliente WEB tradicional por un cliente Flutter único que genera código para múltiples plataformas.

El flujo sigue el esquema clásico de separación de responsabilidades:

1.  **Capa del Cliente (Frontend/Flutter):** La aplicación construida con Flutter gestiona la **interfaz gráfica (UI/UX)**, validaciones básicas y la comunicación con el Backend.
2.  **Capa de Servicios (Backend as a Service - BaaS):** Está compuesta por **Firebase** (Firestore y Cloud Functions). [cite_start]Esta capa implementa las reglas de negocio (funciones *serverless*) y funge como intermediaria entre el cliente y los datos[cite: 31, 75].
3.  **Capa de Datos:** Compuesta por **Cloud Firestore** (NoSQL) para los datos en tiempo real y **Firebase Storage** para archivos y documentos.

**Modelo de Arquitectura (Conceptual):**
[Dispositivos (Web, Android, iOS)]
| (Flutter Dart/REST)
[Capa del Cliente: Aplicación Flutter]
| (REST / Firestore SDKs)
[Capa de Servicios/BaaS: Firebase Functions / Firestore]
|
[Capa de Datos: Cloud Firestore / Firebase Storage]

### 2.2. Diseño e Implementación Estratégica

La estrategia se centra en aprovechar la **integración nativa** de Flutter y Firebase para optimizar el desarrollo.

| Componente | Tecnología Principal | Propósito en el Stack |
| :--- | :--- | :--- |
| **Frontend/Cliente** | **Flutter (Dart)** | Código único. UI declarativa y alto rendimiento nativo. |
| **Backend/BaaS** | **Firebase** | Provee servicios de DB, Auth y *serverless* con la mejor integración para Dart. |
| **Base de Datos** | **Cloud Firestore** | Escalable y con sincronización en tiempo real (NoSQL) para un CRM dinámico. |
| **Autenticación** | **Firebase Authentication** | Gestión de usuarios y sesiones, reemplazando la necesidad de implementar filtros de login manuales (como *LoginFilter* en Spring [cite: 374]). |
| **Hosting Web** | **AWS Amplify Hosting** | Despliegue de la salida **Flutter Web** a la infraestructura corporativa de AWS, usando CDN para performance. |

---

## 3. Stack Tecnológico

El siguiente es el detalle del *stack* tecnológico utilizado en la plataforma, basado en el principio de menor fricción y mayor rendimiento para un desarrollo *Cross-Platform*[cite: 88].

### Backend & Serverless

| Categoría | Tecnología | Versión/Detalle | Función |
| :--- | :--- | :--- | :--- |
| **BaaS** | Firebase | N/A | Proveedor de Backend As a Service. |
| **Base de Datos** | Cloud Firestore | NoSQL Documental | Almacenamiento primario y sincronización en tiempo real. |
| **Lógica de Negocio** | Cloud Functions | Node.js (Recomendado) | Ejecución de lógica *serverless* y transacciones seguras (ej. pagos, notificaciones)[cite: 91, 92]. |
| **Almacenamiento Archivos** | Firebase Storage | N/A | Almacenamiento escalable de documentos, imágenes y archivos. |
| **Hosting Web** | AWS Amplify Hosting | N/A | Servicio de AWS para el despliegue del sitio Web estático con CDN. |

### Frontend (Cliente Cross-Platform)

| Categoría | Tecnología | Versión/Detalle | Función |
| :--- | :--- | :--- | :--- |
| **Framework** | **Flutter** | Última Stable | Motor UI declarativo de Google. |
| **Lenguaje** | **Dart** | Tipado estricto | Lenguaje optimizado para el cliente, usado para toda la lógica de la aplicación. |
| **Gestión de Estado** | Riverpod | N/A | Librería recomendada para la gestión de estado escalable e inmutable. |

### Aseguramiento de Calidad del Software (QA)

| Categoría | Tecnología | Detalle | Función |
| :--- | :--- | :--- | :--- |
| **Unitarias / Widgets** | Flutter Testing Framework | Integrado | Pruebas de lógica de negocio y pruebas de renderizado de componentes (Widgets). |
| **Integración / E2E** | Flutter Integration Tests | N/A | Pruebas de flujo de usuario en dispositivos reales o simulados. |

---

## 4. Estándares y Lineamientos de Desarrollo (DevOps)

### 4.1. Control de Versiones (Git)

Se seguirá el estándar **GitFlow** [cite: 160], asegurando que todo nuevo desarrollo parta de la rama `develop`[cite: 161]. Los nombres de ramas y *commits* deben ser siempre en inglés[cite: 162].

* **Estructura de Ramas:** `feature/`, `fix/`, `hotFix/`, `release/`, `develop`, `master`[cite: 166, 167, 168, 169, 170, 171].
* **Pull Requests (PR):** Todo PR debe ser creado para actualizar a `develop` y debe tener **mínimo una aprobación** de otro desarrollador[cite: 179, 180]. La estrategia de *merge* será con **squash commit**[cite: 183].

### 4.2. Integración Continua y Despliegue (CI/CD)

El *pipeline* se orquestará en **GitHub Actions** y tendrá un flujo de etapas (Stages) similar al modelo de referencia, asegurando la calidad y automatizando el despliegue a los dos ecosistemas (Google y AWS).

| Etapa del Pipeline (Commit Stage) | Tarea Específica | Lineamiento de Aceptación |
| :--- | :--- | :--- |
| **Compile** | `flutter pub get` & `flutter build` | La compilación de Flutter y Dart debe ser exitosa. Si arroja error, el *pipeline* se detiene[cite: 256]. |
| **Commit Tests** | `flutter test` | Ejecuta pruebas unitarias y de *widgets*. El *code coverage* debe tener un porcentaje de aceptación de **al menos 70%**[cite: 189]. |
| **Code Analysis** | Dart Analyzer / Linting | Verificación de legibilidad, mantenibilidad y sintaxis del código Dart/Flutter. Si arroja error, el *pipeline* se detiene[cite: 294]. |
| **Deploy** | **Fastlane & AWS Actions** | El *pipeline* realizará de forma automática el *deploy* de acuerdo al *stage* definido[cite: 211]: **Web a AWS Amplify Hosting** y **Mobile a Stores** (vía Fastlane). |

---

## 5. Requisitos No Funcionales (RNF)

### 5.1. Requisitos de Performance

* **Tiempo de Carga (Web/Mobile):** El tiempo para la carga inicial de la aplicación no será mayor a **10 segundos**[cite: 301].
* **Tiempo de Búsqueda:** El sistema, al realizar búsquedas complejas en Firestore, no debe exceder los **15 segundos**[cite: 302].

### 5.2. Requisitos de Seguridad

* **Autenticación:** Todos los usuarios deben estar autenticados en la plataforma (Firebase Auth)[cite: 308]. Únicamente los usuarios autenticados están autorizados para ver el contenido[cite: 312].
* **Contraseñas:** Las contraseñas deben cumplir un nivel de complejidad mínima (8 caracteres, 1 mayúscula, 1 número y 1 carácter especial)[cite: 313, 314]. Deben ser encriptadas antes de ser almacenadas (gestionado por Firebase Auth)[cite: 315].
* **Seguridad API (Cliente/Backend):** Se implementará **JSON Web Token (JWT)** para la autenticación de servicios RESTful[cite: 317, 325]. Firebase Auth maneja la generación, firma y validación de los tokens[cite: 326, 327].

### 5.3. Requisitos de Escalabilidad

* **División de Capas:** El diseño del sistema contempla la clara **división entre los datos y la lógica de la aplicación** (Flutter vs. Firebase) para optimizar la escalabilidad[cite: 321].
* **Serverless:** El uso de **Cloud Functions** y **Firestore** garantiza una escalabilidad horizontal automática, adaptándose a la concurrencia de clientes sin intervención manual de infraestructura.
* **Migración:** La separación del *backend* y *frontend* garantiza la posibilidad de migrar a otras plataformas o servicios móviles futuros[cite: 323]