# Phase 15: Testing Angular Applications

> Testing is essential for building robust, maintainable, and bug-free Angular applications. This phase covers the fundamentals and best practices for unit testing, integration testing, and end-to-end (E2E) testing in Angular.

---

## 15.1 Why Test Angular Apps?

- **Catch bugs early** before they reach production
- **Refactor with confidence**
- **Document expected behavior**
- **Enable continuous integration (CI)**

---

## 15.2 Types of Tests

| Type                | Purpose                                 | Tools           |
|---------------------|-----------------------------------------|-----------------|
| Unit Test           | Test individual functions/components    | Jasmine, Karma  |
| Integration Test    | Test how components/services work together | Jasmine, Karma  |
| End-to-End (E2E)    | Test the app as a user would            | Protractor, Cypress |

---

## 15.3 Unit Testing Components

- Use Angular's `TestBed` to configure a testing module
- Test component logic, template bindings, and events
- Mock dependencies (services, inputs, outputs)

**Example:**
```typescript
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MyComponent } from './my.component';

describe('MyComponent', () => {
  let component: MyComponent;
  let fixture: ComponentFixture<MyComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [MyComponent],
    });
    fixture = TestBed.createComponent(MyComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
```

---

## 15.4 Testing Services

- Use `TestBed.inject()` to get service instances
- Mock HTTP requests with `HttpTestingController`

---

## 15.5 End-to-End (E2E) Testing

- Simulate real user scenarios
- Use Protractor (legacy) or Cypress (modern)
- Write tests that interact with the UI and assert outcomes

---

## 15.6 Best Practices

- Write tests as you develop features
- Keep tests fast and isolated
- Use mocks and spies for dependencies
- Run tests automatically in CI pipelines

---

## 15.7 Resources

- [Angular Testing Guide](https://angular.io/guide/testing)
- [Jasmine Documentation](https://jasmine.github.io/)
- [Cypress Documentation](https://docs.cypress.io/)
