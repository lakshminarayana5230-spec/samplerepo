# college-poc

Spring Boot (Maven) + PostgreSQL + Flyway + Swagger UI demo for CRUD on:
- Course
- Student
- Enrollment
- Payment

## Database setup (collegedb)

This project uses PostgreSQL.

### 1) Create database `collegedb`

Flyway can create the **schema** (`college`) and tables, but **it cannot create the database** itself.

Create `collegedb` using one of these:

**Option A: pgAdmin**
1. Open pgAdmin
2. Create Database → `collegedb`

**Option B: psql** (if installed)
```powershell
psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE DATABASE collegedb;"
```

If `psql` is not recognized, add PostgreSQL bin folder to PATH, e.g.
`C:\Program Files\PostgreSQL\16\bin`.

### 2) Configure credentials

Defaults are in `src/main/resources/application.yml`:
- URL: `jdbc:postgresql://localhost:5432/collegedb`
- username: `postgres`
- password: `postgres`

## Flyway migrations

Migrations are in:
- `src/main/resources/db/migration/`

On application startup, Flyway will:
1. Create schema `college` (migration `V0__create_schema.sql`)
2. Create tables (migration `V1__init.sql`)

## Run the application

```powershell
mvn spring-boot:run
```

App runs on:
- http://localhost:8082

Swagger UI:
- http://localhost:8082/swagger-ui

OpenAPI docs:
- http://localhost:8082/v3/api-docs
