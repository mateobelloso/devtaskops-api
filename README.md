# devtaskops-api

> API mínima para gestión de tareas (Node.js + TypeScript + Prisma)

Proyecto API REST simple para gestionar tareas, pensado para desarrollo y despliegue con Docker y monitoreo básico (Prometheus).

**Stack principal**
- Node.js + TypeScript
- Fastify / Express (configuración en el código)
- Prisma (Postgres) para ORM y migraciones
- Docker + docker-compose

Características
- Endpoints para crear, listar, actualizar y eliminar tareas
- Validación de esquemas con TypeScript
- Integración con Prisma y migraciones incluidas
- Métricas expuestas para Prometheus

Requisitos
- Node.js 18+ o compatible
- Docker y docker-compose (opcional, para contenedores)
- Base de datos PostgreSQL (local o en contenedor)

Instalación (desarrollo)

1. Clonar el repositorio

```bash
git clone <tu-repo-url>
cd devtaskops-api
```

2. Instalar dependencias

```bash
npm install
```

3. Configurar variables de entorno

Crear un archivo `.env` en la raíz con las variables necesarias (ejemplo):

```
DATABASE_URL=postgresql://user:password@localhost:5432/devtaskops
PORT=3000
```

4. Ejecutar migraciones de Prisma

```bash
npx prisma migrate deploy
```

5. Ejecutar la aplicación

```bash
npm run dev
```

Docker (opcional)

Levantar servicios con Docker Compose:

```bash
docker-compose up --build
```

Esto iniciará la aplicación y la base de datos definida en `docker-compose.yml`.

Tests

```bash
npm test
```

Estructura relevante
- `src/` : código fuente
- `src/controllers/` : controladores (p. ej. `task.controller.ts`)
- `src/routes/` : definiciones de rutas (p. ej. `task.routes.ts`)
- `prisma/` : esquema y migraciones de la DB
- `monitoring/prometheus.yml` : configuración de Prometheus

Endpoints (resumen)
- `GET /tasks` — Listar tareas
- `POST /tasks` — Crear tarea
- `GET /tasks/:id` — Obtener tarea
- `PUT /tasks/:id` — Actualizar tarea
- `DELETE /tasks/:id` — Eliminar tarea

Monitoreo

La app expone métricas configuradas en `config/metrics.ts` que pueden ser recolectadas por Prometheus. Ver `monitoring/prometheus.yml` para un ejemplo de scrape.

Contribuir

1. Abrir un issue describiendo el cambio
2. Crear una rama con el prefijo `feat/` o `fix/`
3. Hacer un PR apuntando a `main` con descripción y pruebas si aplica