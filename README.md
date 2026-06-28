# Despliegue

## Pre-requisitos

Antes de ejecutar los workflows es necesario contar con:

- Una cuenta activa de AWS Academy.
- Permisos para ejecutar GitHub Actions en el repositorio.
- Los GitHub Repository Secrets configurados.
- Seleccionar el ambiente correspondiente (`develop`, `test` o `prod`).

---

## Variables de entorno

Configurar los siguientes **GitHub Repository Secrets**:

### AWS

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `AWS_REGION`

### Base de datos

- `POSTGRES_USER`
- `DB_PASSWORD`

### Administración

- `ADMIN_USERNAME`
- `ADMIN_PASSWORD`
- `ADMIN_JWT_SECRET`

### SonarQube

- `SONAR_HOST_URL`
- `SONAR_ORG`
- `SONAR_PROJECT_KEY`
- `SONAR_TOKEN`

---

## Instrucciones de despliegue

### 1. Bootstrap Pipeline

Este pipeline debe ejecutarse **una única vez por ambiente**, cuando la infraestructura se crea desde cero.

Su función es resolver la dependencia entre Terraform y Amazon ECR mediante tres etapas:

1. **Terraform Bootstrap:** crea la infraestructura base y los repositorios de Amazon ECR.
2. **Build and Push:** construye y publica las imágenes Docker de todos los microservicios.
3. **Terraform Full:** despliega la infraestructura restante utilizando las imágenes previamente publicadas.

---
### 2. Dispatcher Pipeline

Una vez inicializado el ambiente, los despliegues se realizan mediante el **Dispatcher Pipeline**.

Al ejecutarlo se debe seleccionar:

- Ambiente (`develop`, `test` o `prod`).
- Microservicio específico (`admin`, `cart`, `catalog`, `checkout`, `orders`, `ui`) o todos los servicios.

El pipeline realiza automáticamente las siguientes tareas:

- Determina los servicios a desplegar.
- Ejecuta el Pipeline de Servicios para cada microservicio seleccionado.
- Selecciona el archivo `.tfvars` correspondiente al ambiente.
- Ejecuta el Pipeline de Infraestructura para aplicar los cambios con Terraform.

---
### 3. Pipeline de Servicios

Para cada microservicio se ejecutan las siguientes etapas:

1. Code Scan (Semgrep).
2. SonarQube Quality Analysis.
3. Software Composition Analysis (Trivy).
4. Secret Scan (GitLeaks).
5. Build and Push de la imagen Docker a Amazon ECR.
6. Image Scan (Trivy).
7. Despliegue del servicio en Amazon ECS.

---
## Flujo de despliegue

### Primera ejecución
```
Bootstrap Pipeline
│
├── Terraform Bootstrap
├── Build and Push
└── Terraform
```
# Despliegues posteriores
```
Dispatcher Pipeline
│
├── Selección del ambiente
├── Selección del microservicio
├── Pipeline de Servicios
└── Pipeline de Infraestructura
```