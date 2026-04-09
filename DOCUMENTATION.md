# College Management System - Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [System Architecture](#system-architecture)
4. [Database Schema](#database-schema)
5. [Entity Details](#entity-details)
6. [API Endpoints](#api-endpoints)
7. [Business Logic](#business-logic)
8. [Setup & Configuration](#setup--configuration)
9. [Project Structure](#project-structure)

---

## Project Overview

A RESTful API for managing college operations including students, courses, enrollments, and payments.

### Key Features
- ✅ Complete CRUD operations for Students, Courses, Enrollments, and Payments
- ✅ Built with Spring Boot 4.0.1 and Java 17
- ✅ PostgreSQL database with automated schema management
- ✅ Interactive Swagger UI for API documentation
- ✅ Production-ready with input validation
- ✅ Automated business rules (enrollment status management)

### Application Details
- **Port**: 8082
- **Base URL**: http://localhost:8082
- **Swagger UI**: http://localhost:8082/swagger-ui
- **OpenAPI Docs**: http://localhost:8082/v3/api-docs

---

## Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Backend Framework** | Spring Boot | 4.0.1 |
| **Programming Language** | Java | 17 |
| **Database** | PostgreSQL | Latest |
| **ORM** | Spring Data JPA / Hibernate | Included |
| **Build Tool** | Maven | Latest |
| **API Documentation** | SpringDoc OpenAPI | 2.8.3 |
| **Validation** | Jakarta Validation | Included |
| **Code Generation** | Lombok | Latest |

---

## System Architecture

### Layered Architecture

```
┌─────────────────────────────────────────┐
│         Controller Layer                 │
│   (REST Endpoints, HTTP Handling)        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Service Layer                    │
│   (Business Logic, Transactions)         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Repository Layer                 │
│   (Data Access, JPA)                     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         PostgreSQL Database              │
│   Schema: college                        │
└─────────────────────────────────────────┘
```

### Design Patterns
- **MVC Pattern**: Model-View-Controller with REST
- **Repository Pattern**: Spring Data JPA repositories
- **Dependency Injection**: Spring IoC Container
- **Builder Pattern**: Lombok @Builder for entity creation

---

## Database Schema

### Schema: `college`

```sql
college
├── student (id, name, address, phone_number)
├── course (id, title, code)
├── enrollment (id, student_id, course_id, enrollment_date, enrollment_status)
└── payment (id, enroll_id, student_phone_number, payment_date, payment_status, amount)
```

### Entity Relationships

```
Student (1) ────── (N) Enrollment (N) ────── (1) Course
                           │
                           │ (1)
                           │
                           ▼
                       (N) Payment
```

---

## Entity Details

### 1. Student Entity

**Table**: `college.student`

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Long | Primary Key, Auto-generated | Unique identifier |
| name | String | NOT NULL | Student name |
| address | String | - | Student address |
| phoneNumber | String | NOT NULL | Contact number (supports country codes) |

**Java Class**: `com.college.cms.entity.Student`

```java
@Entity
@Table(name = "student", schema = "college")
public class Student {
    @Id @GeneratedValue
    private Long id;
    private String name;
    private String address;
    private String phoneNumber; // String to support country codes
}
```

---

### 2. Course Entity

**Table**: `college.course`

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Long | Primary Key, Auto-generated | Unique identifier |
| title | String | NOT NULL | Course name |
| code | String | NOT NULL | Unique course code (e.g., MATH-101) |

**Java Class**: `com.college.cms.entity.Course`

```java
@Entity
@Table(name = "course", schema = "college")
public class Course {
    @Id @GeneratedValue
    private Long id;
    private String title;
    private String code;
}
```

---

### 3. Enrollment Entity

**Table**: `college.enrollment`

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Long | Primary Key, Auto-generated | Unique identifier |
| student_id | Long | Foreign Key, NOT NULL | Reference to Student |
| course_id | Long | Foreign Key, NOT NULL | Reference to Course |
| enrollment_date | LocalDate | NOT NULL | Date of enrollment |
| enrollment_status | Enum | NOT NULL | Status: PENDING, ACTIVE, COMPLETED, CANCELLED |

**Java Class**: `com.college.cms.entity.Enrollment`

**Enrollment Status Enum**:
- `PENDING` - Initial status after enrollment creation
- `ACTIVE` - Set automatically after successful payment
- `COMPLETED` - Course completed
- `CANCELLED` - Enrollment cancelled

```java
@Entity
@Table(name = "enrollment", schema = "college")
public class Enrollment {
    @Id @GeneratedValue
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    @ManyToOne(optional = false)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(name = "enrollment_date", nullable = false)
    private LocalDate enrollmentDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "enrollment_status", nullable = false)
    private EnrollmentStatus enrollmentStatus;
}
```

---

### 4. Payment Entity

**Table**: `college.payment`

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | Long | Primary Key, Auto-generated | Unique identifier |
| enroll_id | Long | Foreign Key, NOT NULL | Reference to Enrollment |
| student_phone_number | String | - | Cached phone for search/compatibility |
| payment_date | LocalDate | - | Date of payment |
| payment_status | Enum | NOT NULL | Status: PENDING, SUCCESS, FAILED |
| amount | Double | NOT NULL | Payment amount |

**Java Class**: `com.college.cms.entity.Payment`

**Payment Status Enum**:
- `PENDING` - Payment initiated
- `SUCCESS` - Payment successful (triggers enrollment ACTIVE status)
- `FAILED` - Payment failed

```java
@Entity
@Table(name = "payment", schema = "college")
public class Payment {
    @Id @GeneratedValue
    private Long id;

    @JsonIgnore
    @ManyToOne(optional = false)
    @JoinColumn(name = "enroll_id", nullable = false)
    private Enrollment enrollment;

    @Column(name = "student_phone_number")
    private String studentPhoneNumber;

    @Column(name = "payment_date")
    private LocalDate paymentDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "payment_status", nullable = false)
    private PaymentStatus paymentStatus;

    private Double amount;
}
```

---

## API Endpoints

### Student API

**Base Path**: `/students`

| Method | Endpoint | Description | Request Body | Response Code |
|--------|----------|-------------|--------------|---------------|
| GET | `/students` | List all students | - | 200 OK |
| GET | `/students/{id}` | Get student by ID | - | 200 OK |
| GET | `/students/by-phone?phoneNumber={phone}` | Get student by phone | - | 200 OK |
| POST | `/students` | Create new student | StudentRequest | 201 Created |
| PUT | `/students/{id}` | Update student | StudentRequest | 200 OK |
| DELETE | `/students/{id}` | Delete student | - | 204 No Content |

**StudentRequest Schema**:
```json
{
  "name": "John Doe",
  "address": "Hyderabad, India",
  "phoneNumber": "+91-9876543210"
}
```

---

### Course API

**Base Path**: `/courses`

| Method | Endpoint | Description | Request Body | Response Code |
|--------|----------|-------------|--------------|---------------|
| GET | `/courses` | List all courses | - | 200 OK |
| GET | `/courses/{id}` | Get course by ID | - | 200 OK |
| POST | `/courses` | Create new course | CourseRequest | 201 Created |
| PUT | `/courses/{id}` | Update course | CourseRequest | 200 OK |
| DELETE | `/courses/{id}` | Delete course | - | 204 No Content |

**CourseRequest Schema**:
```json
{
  "title": "Mathematics",
  "code": "MATH-101"
}
```

---

### Enrollment API

**Base Path**: `/enrollments`

| Method | Endpoint | Description | Request Body | Response Code |
|--------|----------|-------------|--------------|---------------|
| GET | `/enrollments` | List all enrollments | - | 200 OK |
| GET | `/enrollments/{id}` | Get enrollment by ID | - | 200 OK |
| POST | `/enrollments` | Create enrollment | EnrollmentRequest | 201 Created |
| PUT | `/enrollments/{id}` | Update enrollment | EnrollmentRequest | 200 OK |
| DELETE | `/enrollments/{id}` | Delete enrollment | - | 204 No Content |

**EnrollmentRequest Schema**:
```json
{
  "studentId": 1,
  "courseId": 1,
  "enrollmentDate": "2026-01-23"
}
```

**Notes**:
- `enrollmentDate` defaults to today if omitted
- Initial status is automatically set to `PENDING`
- Status cannot be manually updated via API (managed by business logic)

---

### Payment API

**Base Path**: `/payments`

| Method | Endpoint | Description | Request Body | Response Code |
|--------|----------|-------------|--------------|---------------|
| GET | `/payments` | List all payments | - | 200 OK |
| GET | `/payments/{id}` | Get payment by ID | - | 200 OK |
| POST | `/payments` | Create payment | PaymentRequest | 201 Created |
| PUT | `/payments/{id}` | Update payment | PaymentRequest | 200 OK |
| DELETE | `/payments/{id}` | Delete payment | - | 204 No Content |

**PaymentRequest Schema**:
```json
{
  "enrollmentId": 1,
  "paymentDate": "2026-01-23",
  "amount": 250.0
}
```

**PaymentResponse Schema**:
```json
{
  "id": 1,
  "enrollmentId": 1,
  "studentPhoneNumber": "+91-9876543210",
  "paymentDate": "2026-01-23",
  "paymentStatus": "SUCCESS",
  "amount": 250.0
}
```

**Notes**:
- `paymentDate` defaults to today if omitted
- `studentPhoneNumber` is auto-populated from enrollment

---

## Business Logic

### Enrollment Status Management

**Automatic Status Transitions**:

```
Create Enrollment → PENDING
      ↓
Payment SUCCESS → ACTIVE
      ↓
Manual Update → COMPLETED / CANCELLED
```

**Rules**:
1. New enrollments always start with `PENDING` status
2. Enrollment status **cannot** be manually updated via `/enrollments` API
3. Status automatically changes to `ACTIVE` when a payment with `SUCCESS` status is created
4. Future statuses (`COMPLETED`, `CANCELLED`) can be managed via business logic

### Payment Processing

**Workflow**:
1. Create payment linked to an enrollment (via `enrollmentId`)
2. System validates enrollment exists
3. Auto-populates `studentPhoneNumber` from the enrolled student
4. If `paymentDate` is null, defaults to current date
5. Initial payment status: `PENDING`
6. When payment status becomes `SUCCESS`:
   - Triggers enrollment status update to `ACTIVE`

### Data Validation

**Controller Layer**:
- `@Valid` annotation on request bodies
- `@NotBlank`, `@NotNull` constraints
- HTTP 400 Bad Request for validation errors

**Service Layer**:
- Foreign key validation (student/course/enrollment existence)
- Throws `IllegalArgumentException` for invalid references
- Business rule enforcement

---

## Setup & Configuration

### Prerequisites

1. **Java 17** or higher
2. **Maven** 3.6+
3. **PostgreSQL** (any recent version)

### Database Setup

#### Step 1: Create Database

**Option A: Using pgAdmin**
1. Open pgAdmin
2. Right-click Databases → Create → Database
3. Name: `collegedb`

**Option B: Using psql**
```bash
psql -h localhost -p 5432 -U postgres -d postgres -c "CREATE DATABASE collegedb;"
```

#### Step 2: Configuration

Database credentials are in `src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/collegedb
    username: postgres
    password: postgres
```

**Note**: Flyway will automatically create the `college` schema and tables on application startup.

### Running the Application

```bash
# From project root directory
mvn spring-boot:run
```

The application will start on **http://localhost:8082**

### Accessing API Documentation

Once the application is running:

- **Swagger UI**: http://localhost:8082/swagger-ui
  - Interactive API documentation
  - Test endpoints directly in browser

- **OpenAPI JSON**: http://localhost:8082/v3/api-docs
  - Raw OpenAPI 3 specification

---

## Project Structure

```
college-poc/
├── src/
│   └── main/
│       ├── java/com/college/cms/
│       │   ├── CollegeManagementApplication.java  # Main class
│       │   ├── config/
│       │   │   ├── OpenApiConfig.java             # Swagger configuration
│       │   │   └── SwaggerTagOrderConfig.java     # Tag ordering
│       │   ├── controller/                        # REST Controllers
│       │   │   ├── StudentController.java
│       │   │   ├── CourseController.java
│       │   │   ├── EnrollmentController.java
│       │   │   └── PaymentController.java
│       │   ├── service/                           # Business Logic
│       │   │   ├── StudentService.java
│       │   │   ├── CourseService.java
│       │   │   ├── EnrollmentService.java
│       │   │   └── PaymentService.java
│       │   ├── repo/                              # Data Access
│       │   │   ├── StudentRepo.java
│       │   │   ├── CourseRepo.java
│       │   │   ├── EnrollmentRepo.java
│       │   │   └── PaymentRepo.java
│       │   └── entity/                            # JPA Entities
│       │       ├── Student.java
│       │       ├── Course.java
│       │       ├── Enrollment.java
│       │       └── Payment.java
│       └── resources/
│           ├── application.yml                    # Configuration
│           └── db/migration/                      # Flyway SQL scripts
│               ├── V0__create_schema.sql
│               └── V1__init.sql
├── pom.xml                                        # Maven dependencies
└── README.md                                       # Setup guide
```

---

## Key Maven Dependencies

```xml
<!-- Spring Boot Starters -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>

<!-- Database -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
</dependency>

<!-- API Documentation -->
<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.8.3</version>
</dependency>

<!-- Code Generation -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
</dependency>
```

---

## Design Patterns & Best Practices

### Separation of Concerns
- **Controllers**: Handle HTTP requests, response formatting, validation
- **Services**: Implement business logic, manage transactions
- **Repositories**: Provide data access abstraction
- **Entities**: Represent domain model

### RESTful API Design
- Proper HTTP methods (GET, POST, PUT, DELETE)
- Meaningful status codes (200, 201, 204, 400, 404)
- Resource-based URLs
- JSON request/response format

### Data Integrity
- Foreign key constraints
- NOT NULL constraints on critical fields
- Enum types for status fields
- Validation at multiple layers

### Code Quality
- Lombok annotations reduce boilerplate
- OpenAPI annotations for documentation
- Consistent naming conventions
- Modular package structure

---

## Future Enhancements

### Security
- [ ] Spring Security integration
- [ ] JWT token-based authentication
- [ ] Role-based access control (RBAC)

### Features
- [ ] Pagination for list endpoints
- [ ] Search and filtering (by name, code, status, etc.)
- [ ] Email notifications (enrollment confirmation, payment receipt)
- [ ] Grade management module
- [ ] Attendance tracking
- [ ] Course scheduling
- [ ] Student performance reports

### Technical Improvements
- [ ] Caching (Redis/Caffeine)
- [ ] API rate limiting
- [ ] Comprehensive unit tests
- [ ] Integration tests
- [ ] Docker containerization
- [ ] CI/CD pipeline
- [ ] Monitoring and logging (ELK stack)
- [ ] API versioning

---

## Testing the API

### Example: Create a Student

**Request**:
```bash
curl -X POST http://localhost:8082/students \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "address": "Hyderabad, India",
    "phoneNumber": "+91-9876543210"
  }'
```

**Response** (201 Created):
```json
{
  "id": 1,
  "name": "John Doe",
  "address": "Hyderabad, India",
  "phoneNumber": "+91-9876543210"
}
```

### Example: Create a Course

**Request**:
```bash
curl -X POST http://localhost:8082/courses \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Mathematics",
    "code": "MATH-101"
  }'
```

### Example: Enroll Student in Course

**Request**:
```bash
curl -X POST http://localhost:8082/enrollments \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": 1,
    "courseId": 1,
    "enrollmentDate": "2026-01-23"
  }'
```

**Response**:
```json
{
  "id": 1,
  "student": { "id": 1, "name": "John Doe", ... },
  "course": { "id": 1, "title": "Mathematics", ... },
  "enrollmentDate": "2026-01-23",
  "enrollmentStatus": "PENDING"
}
```

### Example: Create Payment

**Request**:
```bash
curl -X POST http://localhost:8082/payments \
  -H "Content-Type: application/json" \
  -d '{
    "enrollmentId": 1,
    "paymentDate": "2026-01-23",
    "amount": 250.0
  }'
```

**Response**:
```json
{
  "id": 1,
  "enrollmentId": 1,
  "studentPhoneNumber": "+91-9876543210",
  "paymentDate": "2026-01-23",
  "paymentStatus": "SUCCESS",
  "amount": 250.0
}
```

After this payment, the enrollment status automatically changes from `PENDING` to `ACTIVE`.

---

## Troubleshooting

### Database Connection Issues
```
Error: Could not connect to database
```
**Solution**:
1. Verify PostgreSQL is running
2. Check database `collegedb` exists
3. Verify credentials in `application.yml`
4. Ensure PostgreSQL port 5432 is not blocked

### Port Already in Use
```
Error: Port 8082 is already in use
```
**Solution**: Change port in `application.yml`:
```yaml
server:
  port: 8083
```

### Flyway Migration Errors
```
Error: Flyway migration failed
```
**Solution**:
1. Ensure database `collegedb` exists
2. Check SQL syntax in migration files
3. Drop and recreate database if needed

---

## Resources

### Technology Documentation
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Data JPA](https://spring.io/projects/spring-data-jpa)
- [SpringDoc OpenAPI](https://springdoc.org)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Lombok](https://projectlombok.org)

### Project Files
- `README.md` - Quick start guide
- `pom.xml` - Maven configuration
- `application.yml` - Application configuration

---

**Document Version**: 1.0
**Last Updated**: March 2026
**Application Version**: 0.0.1-SNAPSHOT
