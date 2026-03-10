# RevWorkForce – Project Questions & Answers

## (Easy → Medium → Hard → Scenario-Based)

> A comprehensive question bank based on the **RevWorkForce Human Resource Management System** built with **Spring Boot 3.2.3**, **Oracle Database (PL/SQL)**, **Spring JDBC**, **Spring Security**, **Thymeleaf**, and **Lombok**.

---

## 📗 SECTION 1 – EASY QUESTIONS

### General / Overview

**Q1. What is RevWorkForce?**
**Ans:** RevWorkForce is a full-stack monolithic Human Resource Management System (HRMS) that streamlines employee directory management, leave tracking, goal setting, and performance reviews with role-based access control.

**Q2. What programming language and Java version does the project use?**
**Ans:** Java 17.

**Q3. Which Spring Boot version is used in this project?**
**Ans:** Spring Boot 3.2.3 (defined in `pom.xml` under `spring-boot-starter-parent`).

**Q4. What database is used in this project?**
**Ans:** Oracle Database (tested with the `ORCLPDB` pluggable database at `localhost:1521`).

**Q5. What build tool does the project use?**
**Ans:** Apache Maven (using the Maven Wrapper – `mvnw`).

**Q6. What is the role of Thymeleaf in this project?**
**Ans:** Thymeleaf is used for server-side rendering of HTML templates. It serves the base HTML pages (dashboard, leaves, login, etc.) which are then enhanced by jQuery for dynamic behavior.

**Q7. What is Lombok and why is it used here?**
**Ans:** Lombok is a Java library that reduces boilerplate code. In this project, annotations like `@Data`, `@Builder`, `@NoArgsConstructor`, `@AllArgsConstructor`, and `@RequiredArgsConstructor` are used to auto-generate getters, setters, constructors, `toString()`, `equals()`, and `hashCode()` methods.

**Q8. List the main modules/features of RevWorkForce.**
**Ans:**
1. Authentication & Profile
2. Dashboard (role-customized)
3. Leave Management
4. Goal Management
5. Performance Reviews
6. Company Directory & Announcements

**Q9. What are the three user roles in the application?**
**Ans:** `ADMIN`, `MANAGER`, and `EMPLOYEE` (defined as an enum inside the `User` model).

**Q10. How do you run this application locally?**
**Ans:**
```bash
./mvnw clean install
./mvnw spring-boot:run
```
Then navigate to `http://localhost:8080`.

---

### Model / POJO Questions

**Q11. How many model classes are there? Name them.**
**Ans:** 10 model classes – `User`, `LeaveRequest`, `LeaveBalance`, `LeaveType`, `Goal`, `PerformanceReview`, `Announcement`, `Department`, `Holiday`, `Notification`.

**Q12. What annotation is used to generate the builder pattern on model classes?**
**Ans:** `@Builder` from Lombok.

**Q13. What does `@Builder.Default` do in the `User` model?**
**Ans:** It sets a default value when using the builder pattern. For example, `@Builder.Default private boolean active = true;` ensures that new users are active by default.

**Q14. What fields does the `User` model contain?**
**Ans:** `id`, `name`, `email`, `password`, `employeeId`, `role`, `department`, `designation`, `managerId`, `phone`, `address`, `emergencyContact`, `joiningDate`, `active`, `salary`.

**Q15. What is a "transient field" in the `LeaveRequest` model?**
**Ans:** The `employeeName` field is called a transient/display field. It is not stored in the `leave_requests` table but is populated at query time for display purposes (e.g., via a JOIN).

---

## 📘 SECTION 2 – MEDIUM QUESTIONS

### Architecture & Layering

**Q16. Describe the layered architecture of RevWorkForce.**
**Ans:** The project follows a clean layered monolithic architecture:
1. **Frontend Layer** – Thymeleaf templates + jQuery/AJAX
2. **Controller Layer** – `@RestController` classes handle HTTP requests
3. **Service Layer** – Business logic, validation, transaction orchestration
4. **DAO (Data Access) Layer** – Spring JDBC (`JdbcTemplate` + `SimpleJdbcCall`) invoking Oracle PL/SQL procedures
5. **Database Layer** – Oracle DB with 10+ tables and 30+ PL/SQL procedures/functions

**Q17. Why is JPA/Hibernate NOT used in this project?**
**Ans:** The project deliberately uses Spring JDBC with `JdbcTemplate` and `SimpleJdbcCall` to directly invoke Oracle PL/SQL stored procedures. This gives full control over SQL, leverages Oracle's procedural capabilities, and avoids the overhead of an ORM.

**Q18. What is the difference between `JdbcTemplate` and `SimpleJdbcCall` as used in the DAO layer?**
**Ans:**
- `JdbcTemplate` is used for direct SQL queries (e.g., `SELECT * FROM users WHERE id = ?`).
- `SimpleJdbcCall` is used to call Oracle PL/SQL stored procedures (e.g., `sp_register_user`, `sp_update_user`).

**Q19. What is a `RowMapper` and how is it used in `UserDao`?**
**Ans:** A `RowMapper` is a Spring JDBC interface that maps a `ResultSet` row to a Java object. In `UserDao`, a `RowMapper<User>` lambda maps each database row to a `User` POJO using `rs.getString()`, `rs.getLong()`, etc.

**Q20. How does the `UserDao.save()` method work?**
**Ans:** It creates a `SimpleJdbcCall` pointing to the `sp_register_user` stored procedure, builds a parameter map with all user fields (prefixed with `p_`), executes the call, and retrieves the generated `P_USER_ID` from the result map.

---

### Spring Security

**Q21. What password encoder is used and why?**
**Ans:** `NoOpPasswordEncoder` is used (passwords stored as plain text). The `@SuppressWarnings("deprecation")` annotation acknowledges that this is deprecated — it was chosen for development simplicity but is NOT recommended for production (BCrypt should be used instead).

**Q22. What authentication mechanism does the project use?**
**Ans:** Session-based authentication using `HttpSession`. The `AuthController.login()` method:
1. Validates credentials via `UserService.authenticate()`
2. Stores user info in the session (`userId`, `userRole`, `userName`, `userEmail`)
3. Creates a `UsernamePasswordAuthenticationToken` and sets it in `SecurityContextHolder`
4. Persists the `SecurityContext` in the session

**Q23. Which URLs are publicly accessible without authentication?**
**Ans:** `/`, `/login`, `/register`, `/api/auth/**`, `/css/**`, `/js/**`, `/images/**`, `/webjars/**` — as configured in the `SecurityFilterChain`.

**Q24. How is CSRF handled in this application?**
**Ans:** CSRF protection is disabled via `.csrf(csrf -> csrf.disable())` in `SecurityConfig`. This is because the app uses REST APIs with AJAX calls (not traditional form submissions).

**Q25. What happens when an unauthenticated user tries to access a protected page?**
**Ans:** The `exceptionHandling` configuration redirects them to `/login` using a custom `authenticationEntryPoint`.

**Q26. How does logout work?**
**Ans:** Logout is configured at `/api/auth/logout`. It invalidates the `HttpSession`, deletes the `JSESSIONID` cookie, and redirects to `/login`.

---

### Service Layer Logic

**Q27. Explain the user registration flow in `UserService.register()`.**
**Ans:**
1. Check if email already exists → throw exception if duplicate
2. Set `active = true`, default role to `EMPLOYEE`, auto-generate `employeeId` if missing, set `joiningDate` to today if null
3. Call `userDao.save()` which invokes `sp_register_user`
4. Initialize leave balances for all leave types for the new user
5. Return the saved user

**Q28. How does user authentication work in `UserService.authenticate()`?**
**Ans:** It fetches the user by email from the database, then does a plain-text password comparison using `password.equals(userOpt.get().getPassword())`. If the user is deactivated (`active = false`), it throws an exception.

**Q29. What validations are performed when applying for leave?**
**Ans:**
1. Start date must be before or equal to end date
2. Start date cannot be in the past
3. Leave balance must be sufficient for the requested number of days

**Q30. What happens when a manager approves a leave request?**
**Ans:**
1. Validate that the leave status is `PENDING`
2. Calculate the number of days
3. Call `leaveRequestDao.approveLeave()` which updates the status and deducts from the leave balance
4. Send a notification to the employee

**Q31. Can only pending leave requests be cancelled?**
**Ans:** Yes. The `cancelLeave()` method in `LeaveService` throws a `RuntimeException("Only pending leaves can be cancelled")` if the status is not `PENDING`.

**Q32. What happens when a leave is rejected? Is a comment mandatory?**
**Ans:** Yes, a comment is mandatory when rejecting leave. The service throws `RuntimeException("Comment is mandatory when rejecting leave")` if the comment is null or empty. A notification with the rejection reason is sent to the employee.

---

### Data Initialization

**Q33. What is the purpose of `DataInitializer.java`?**
**Ans:** It implements `CommandLineRunner` and seeds initial data when the application starts — departments, leave types, users (admin, manager, 3 employees), leave balances, holidays, and announcements. It checks if data already exists before seeding.

**Q34. How many pre-seeded users are created and what are their credentials?**
**Ans:** 5 users:
| Name | Email | Password | Role |
|------|-------|----------|------|
| Admin User | admin@revworkforce.com | admin123 | ADMIN |
| Manager User | manager@revworkforce.com | manager123 | MANAGER |
| John Employee | employee@revworkforce.com | employee123 | EMPLOYEE |
| Jane Developer | jane@revworkforce.com | jane123 | EMPLOYEE |
| Bob Analyst | bob@revworkforce.com | bob123 | EMPLOYEE |

**Q35. What leave types are seeded and how many default days does each have?**
**Ans:**
| Leave Type | Default Days |
|------------|-------------|
| Casual Leave | 12 |
| Sick Leave | 10 |
| Paid Leave | 15 |
| Maternity Leave | 180 |

---

## 📙 SECTION 3 – HARD / IN-DEPTH QUESTIONS

### Security & Best Practices

**Q36. What security vulnerabilities exist in the current implementation?**
**Ans:**
1. **Plain-text passwords** – `NoOpPasswordEncoder` stores passwords without hashing; BCrypt should be used
2. **CSRF disabled** – Potential for cross-site request forgery attacks
3. **No input sanitization** – SQL injection risk (though parameterized queries help mitigate this)
4. **No rate limiting** – No protection against brute-force login attacks
5. **Generic error messages** – `RuntimeException` is thrown instead of custom exception classes

**Q37. How would you migrate from `NoOpPasswordEncoder` to `BCryptPasswordEncoder`?**
**Ans:**
1. Change `passwordEncoder()` bean to return `new BCryptPasswordEncoder()`
2. Update `UserService.register()` to hash passwords before saving: `user.setPassword(passwordEncoder.encode(user.getPassword()))`
3. Update `UserService.authenticate()` to use `passwordEncoder.matches(rawPassword, hashedPassword)`
4. Run a migration script to hash all existing plain-text passwords in the database
5. Remove the password rollback logic from `DataInitializer`

**Q38. Why does the project use `HttpSessionSecurityContextRepository` explicitly?**
**Ans:** Spring Security 6.x (used with Spring Boot 3.x) changed the default `SecurityContextRepository` from session-based to `RequestAttributeSecurityContextRepository`. Since this app relies on session-based auth, it explicitly configures `HttpSessionSecurityContextRepository` to persist the `SecurityContext` across requests.

**Q39. In `AuthController.login()`, why is the SecurityContext manually stored in the session?**
**Ans:** Because the app uses a custom login endpoint (`/api/auth/login`) instead of Spring Security's form login. The `SecurityContextHolder.getContext()` must be manually persisted in the session using `session.setAttribute(HttpSessionSecurityContextRepository.SPRING_SECURITY_CONTEXT_KEY, ...)` so that subsequent requests can retrieve the authenticated context.

---

### DAO & Database

**Q40. How does the `searchUsers()` method in `UserDao` work? Is it vulnerable to SQL injection?**
**Ans:** It uses `LIKE` with a wildcard pattern (`%query%`) and passes the pattern as a parameterized argument to `JdbcTemplate.query()`. Since parameterized queries are used, it is NOT vulnerable to SQL injection. However, the `LOWER()` function call on every column may have performance issues without proper indexes.

**Q41. How does Oracle store boolean values in this project?**
**Ans:** Oracle doesn't have a native boolean type for table columns. The `active` field is stored as `NUMBER(1)` where `1 = true` and `0 = false`. The `RowMapper` converts this: `rs.getInt("active") == 1`.

**Q42. What is the significance of using stored procedures over inline SQL for CRUD operations?**
**Ans:**
- **Encapsulation** – Business rules live in the database
- **Performance** – Pre-compiled execution plans
- **Security** – Users only need EXECUTE privilege, not direct table access
- **Reusability** – Same procedure can be called from multiple applications
- **Atomicity** – Complex operations (e.g., approve leave + deduct balance) are atomic

**Q43. How does the `approveLeave` stored procedure handle balance deduction atomically?**
**Ans:** The `sp_approve_leave` procedure (called via `SimpleJdbcCall`) updates the leave status to `APPROVED`, sets the manager comment, and deducts the leave days from the `leave_balances` table — all within a single PL/SQL block, ensuring atomicity.

---

### Design Patterns & OOP

**Q44. What design patterns are used in this project?**
**Ans:**
1. **Builder Pattern** – Lombok `@Builder` on all model classes
2. **Repository Pattern** – DAO classes encapsulate data access logic
3. **Service Layer Pattern** – Business logic separated from controllers
4. **MVC Pattern** – Controller → Service → DAO layering
5. **Dependency Injection** – Constructor injection via `@RequiredArgsConstructor`
6. **Template Method** – `CommandLineRunner` interface in `DataInitializer`

**Q45. Why is constructor-based dependency injection preferred over field injection?**
**Ans:**
1. Makes dependencies explicit and immutable (`final` fields)
2. Easier to write unit tests (inject mocks via constructor)
3. Fails fast at startup if a dependency is missing
4. Recommended by the Spring team as a best practice

**Q46. What is `@RequiredArgsConstructor` and how does it relate to dependency injection?**
**Ans:** It's a Lombok annotation that generates a constructor for all `final` fields. Since Spring performs constructor injection by default when there's only one constructor, this effectively replaces `@Autowired` on each field with clean, immutable DI.

---

### Frontend Integration

**Q47. How do the frontend and backend communicate?**
**Ans:** Thymeleaf serves the initial HTML pages. jQuery then makes AJAX REST API calls (`$.ajax()`) to the `@RestController` endpoints (e.g., `/api/auth/login`, `/api/leaves/apply`). The controllers return JSON responses which jQuery uses to dynamically update the DOM.

**Q48. How does session validation work on the frontend?**
**Ans:** On page load, jQuery calls `GET /api/auth/session`. If the response contains `authenticated: false`, the user is redirected to `/login` via JavaScript. This provides a client-side guard in addition to Spring Security's server-side protection.

---

## 📕 SECTION 4 – SCENARIO-BASED QUESTIONS

**Q49. Scenario: An employee named Priya just joined the company. Walk through what happens in the system when she registers.**
**Ans:**
1. Priya submits registration form → AJAX `POST /api/auth/register` with user details
2. `AuthController.register()` calls `UserService.register()`
3. Service checks `userDao.existsByEmail()` — if email is new, proceeds
4. Sets defaults: `active = true`, `role = EMPLOYEE`, auto-generates `employeeId`, sets `joiningDate = today`
5. Calls `userDao.save()` → executes `sp_register_user` stored procedure → returns generated `userId`
6. Iterates all `LeaveType` records and creates a `LeaveBalance` for each (Casual: 12, Sick: 10, Paid: 15, Maternity: 180)
7. Returns success response with `userId`

**Q50. Scenario: An employee applies for 5 days of Casual Leave but only has 3 days remaining. What happens?**
**Ans:** The `LeaveService.applyLeave()` method calculates the requested days, fetches the employee's `LeaveBalance` for "Casual Leave", and checks `balance.getRemainingDays() < days`. Since 3 < 5, it throws `RuntimeException("Insufficient leave balance. Available: 3 days")` and the leave is not created.

**Q51. Scenario: A manager approves a leave request but the leave was already cancelled by the employee. What happens?**
**Ans:** The `approveLeave()` method checks if `leave.getStatus() != PENDING`. Since the status is `CANCELLED`, it throws `RuntimeException("Leave is not pending")` and the approval fails.

**Q52. Scenario: The admin wants to deactivate an employee. What happens to their data?**
**Ans:** `UserService.deactivate()` calls `userDao.deactivate()` which invokes `sp_deactivate_user`. This sets `active = 0` in the database. The employee's data (leaves, goals, reviews) is preserved but the user cannot log in — `UserService.authenticate()` throws `RuntimeException("Account is deactivated")`.

**Q53. Scenario: Two users try to register with the same email simultaneously. How does the system handle it?**
**Ans:** `UserService.register()` checks `userDao.existsByEmail()` first. However, there's a potential race condition — both threads may pass the check if they execute nearly simultaneously. The stored procedure `sp_register_user` or a UNIQUE constraint on the `email` column in Oracle would be the actual safeguard. The application-level check provides the first line of defense but is not fully thread-safe without database constraints.

**Q54. Scenario: You need to add a new leave type called "Work From Home" with 20 default days. What changes are needed?**
**Ans:**
1. Admin uses the UI to call `POST /api/admin/leave-types` with `{ "name": "Work From Home", "defaultDays": 20 }`
2. `LeaveService.addLeaveType()` checks if the name already exists, then calls `leaveTypeDao.save()`
3. However, **existing employees will NOT automatically get this balance**. A migration step or admin action would be needed to call `leaveBalanceDao.save()` for each existing employee with the new leave type.

**Q55. Scenario: The application starts but the Oracle database is down. What happens?**
**Ans:** The `DataInitializer.run()` method tries `SELECT COUNT(*) FROM users`. This will throw an exception which is caught, logging `"Tables may not exist yet."` Then it attempts to seed data, which will also fail with an error logged: `"Error during data initialization: ..."`. The application may still start (Spring Boot doesn't crash for CommandLineRunner exceptions by default) but all API calls will fail with database connectivity errors.

**Q56. Scenario: How would you add pagination to the employee directory?**
**Ans:**
1. Modify `UserDao.findAll()` to accept `page` and `size` parameters
2. Use Oracle's `OFFSET ... FETCH NEXT ... ROWS ONLY` syntax or `ROWNUM` for pagination
3. Add a `countAll()` method to return total records
4. Update the REST endpoint to accept `?page=0&size=10` query params
5. Return a paginated response with `content`, `totalPages`, `totalElements`, `currentPage`

**Q57. Scenario: The project needs to support multiple databases (Oracle + PostgreSQL). What architectural changes are needed?**
**Ans:**
1. Replace `SimpleJdbcCall` (Oracle-specific stored proc calls) with database-agnostic `JdbcTemplate` SQL, or
2. Introduce Spring Data JPA with database-agnostic entity mappings
3. Use Spring Profiles (`application-oracle.properties`, `application-postgres.properties`) for different datasource configs
4. Abstract the DAO layer behind interfaces and provide Oracle/PostgreSQL implementations
5. Replace Oracle-specific SQL syntax (e.g., `ROWNUM`, `NVL`) with ANSI SQL equivalents

**Q58. Scenario: You want to write a unit test for `UserService.register()`. How would you approach it?**
**Ans:**
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock private UserDao userDao;
    @Mock private LeaveBalanceDao leaveBalanceDao;
    @Mock private LeaveTypeDao leaveTypeDao;
    @InjectMocks private UserService userService;

    @Test
    void register_shouldSaveUserAndInitBalances() {
        // Arrange
        User user = User.builder().email("test@test.com").password("pass").build();
        User saved = User.builder().id(1L).email("test@test.com").build();
        when(userDao.existsByEmail("test@test.com")).thenReturn(false);
        when(userDao.save(any())).thenReturn(saved);
        when(leaveTypeDao.findAll()).thenReturn(List.of(
            LeaveType.builder().name("Casual").defaultDays(12).build()
        ));

        // Act
        User result = userService.register(user);

        // Assert
        assertNotNull(result.getId());
        verify(leaveBalanceDao, times(1)).save(any());
    }

    @Test
    void register_duplicateEmail_shouldThrowException() {
        when(userDao.existsByEmail("dup@test.com")).thenReturn(true);
        User user = User.builder().email("dup@test.com").build();
        assertThrows(RuntimeException.class, () -> userService.register(user));
    }
}
```

**Q59. Scenario: The admin wants a report showing department-wise leave utilization. How would you implement it?**
**Ans:**
1. Create a new Oracle stored procedure that JOINs `users`, `leave_balances`, and `leave_requests` grouped by department
2. Add a DAO method calling this procedure via `SimpleJdbcCall`
3. Create a new `LeaveUtilizationReport` model/DTO
4. Add a service method in `LeaveService` or a new `ReportService`
5. Add a `GET /api/admin/reports/leave-utilization` endpoint in `AdminController`
6. Display results in a new Thymeleaf template with a data table/chart

**Q60. Scenario: How would you implement real-time notifications instead of the current database-polling approach?**
**Ans:**
1. Add the `spring-boot-starter-websocket` dependency
2. Configure a `WebSocketMessageBroker` with STOMP protocol
3. Create a `/topic/notifications/{userId}` destination
4. When a notification is created (e.g., leave approved), publish to the user's topic via `SimpMessagingTemplate`
5. On the frontend, connect to the WebSocket and subscribe to the user's notification topic
6. Show real-time toast notifications using JavaScript

---

## 📖 SECTION 5 – VIVA / INTERVIEW STYLE QUESTIONS

**Q61. Why did you choose Oracle over MySQL/PostgreSQL?**
**Ans:** Oracle was chosen to leverage PL/SQL stored procedures for data logic encapsulation, demonstrating enterprise-level database programming skills. Oracle also provides powerful features like sequences, fine-grained access control, and PL/SQL's procedural capabilities.

**Q62. What is the advantage of using `@RestController` over `@Controller`?**
**Ans:** `@RestController` combines `@Controller` and `@ResponseBody`. Every method return value is automatically serialized to JSON (via Jackson) and written to the HTTP response body. `@Controller` would require `@ResponseBody` on each method or return `ModelAndView` for Thymeleaf views.

**Q63. Explain how `@RequiredArgsConstructor` eliminates the need for `@Autowired`.**
**Ans:** `@RequiredArgsConstructor` generates a constructor for all `final` fields. Since Spring auto-detects a single constructor for dependency injection, all the `final` DAO/Service fields are automatically injected without needing `@Autowired`.

**Q64. How does the `@Builder.Default` annotation work?**
**Ans:** When using Lombok's `@Builder`, fields without `@Builder.Default` are initialized to `null`/`0`/`false` regardless of field-level defaults. `@Builder.Default` ensures the field's default value is used when it's not explicitly set in the builder chain. Example: `@Builder.Default private boolean active = true;` ensures `User.builder().build().isActive()` returns `true`.

**Q65. What is `CommandLineRunner` and when does it execute?**
**Ans:** `CommandLineRunner` is a Spring Boot interface with a single `run(String... args)` method. It executes after the application context is fully initialized and all beans are created, but before the app starts accepting requests. It's commonly used for data seeding, migration, and startup tasks.

**Q66. What does `.formLogin(form -> form.disable())` do in SecurityConfig?**
**Ans:** It disables Spring Security's default form-based login page. Since the application uses a custom login page served by Thymeleaf and a custom API endpoint (`/api/auth/login`) for authentication, the default Spring Security login form is unnecessary.

**Q67. How are leave days calculated in the system?**
**Ans:** Using `ChronoUnit.DAYS.between(startDate, endDate) + 1`. The `+1` ensures that both the start and end dates are counted as leave days (inclusive calculation).

**Q68. What is the purpose of `HttpSessionSecurityContextRepository`?**
**Ans:** It stores the `SecurityContext` (containing the authenticated user's details) in the `HttpSession`. This ensures the authentication persists across multiple HTTP requests in the same session, which is essential for stateful session-based authentication.

---

*Document generated based on the RevWorkForce codebase analysis — covering models, controllers, services, DAOs, configuration, and architectural decisions.*
