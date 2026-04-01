---
user-invocable: false
name: typescript-advanced-types
description: Master TypeScript's advanced type system including generics, conditional types, mapped types, template literals, and utility types for building type-safe applications. Use when implementing complex type logic, creating reusable type utilities, or ensuring compile-time type safety in TypeScript projects.
---

**Pattern: Tool Wrapper**

## USE FOR

Say things like:
- "How do I make a type for nested readonly objects?"
- "Write a type-safe generic API client in TypeScript"
- "Help me implement a builder pattern with TypeScript"
- "What's the correct way to use `infer` in conditional types?"
- "Create a DeepPartial utility type"
- "How do I type discriminated unions for a state machine?"
- "Extract the return type of an async function"

## Example

**User says:** "Help me write a DeepReadonly utility type"

**Steps:**
1. Define the base case: primitives return as-is
2. Handle functions: keep them unchanged (don't recurse into them)
3. Recurse into objects: wrap all properties with `readonly` and recurse
4. Test with a nested object type to confirm deep immutability

**Output:**
```typescript
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object
    ? T[P] extends Function ? T[P] : DeepReadonly<T[P]>
    : T[P];
};

// Usage
type Config = DeepReadonly<{
  server: { host: string; port: number };
  db: { url: string; pool: { max: number } };
}>;

// config.server.host = "x"        // ❌ Error: readonly
// config.db.pool.max = 10         // ❌ Error: readonly (deep!)
```

**Reply:** "Here's the `DeepReadonly<T>` utility type using recursive mapped types. It makes all properties—including nested objects—readonly at compile time. Functions are intentionally excluded from recursion so method signatures stay intact. See the `DeepPartial` pattern in this skill for the mutable counterpart."

---

## Prerequisites

- Node.js (for running TypeScript)
- TypeScript (`npm install -g typescript` for `tsc`)
- Recommended: `tsconfig.json` with `"strict": true`

# TypeScript Advanced Types

Comprehensive guidance for mastering TypeScript's advanced type system.

## When to Use This Skill

- Building type-safe libraries or frameworks
- Creating reusable generic components
- Implementing complex type inference logic
- Designing type-safe API clients or form validation
- Implementing type-safe state management
- Migrating JavaScript codebases to TypeScript

**Don't use when:** Simple JavaScript will do — TypeScript adds overhead; only adopt when the codebase benefits from compile-time type safety.

## Core Concepts

### 1. Generics

**Purpose:** Create reusable, type-flexible components while maintaining type safety.

```typescript
function identity<T>(value: T): T { return value; }

interface HasLength { length: number; }
function logLength<T extends HasLength>(item: T): T {
  console.log(item.length);
  return item;
}

function merge<T, U>(obj1: T, obj2: U): T & U {
  return { ...obj1, ...obj2 };
}
```

### 2. Conditional Types

**Purpose:** Create types that depend on conditions, enabling sophisticated type logic.

```typescript
type IsString<T> = T extends string ? true : false;

// Extract return type using infer
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never;

// Distributive conditional types
type ToArray<T> = T extends any ? T[] : never;
type StrOrNumArray = ToArray<string | number>; // string[] | number[]

type TypeName<T> = T extends string ? "string"
  : T extends number ? "number"
  : T extends boolean ? "boolean"
  : T extends Function ? "function"
  : "object";
```

### 3. Mapped Types

**Purpose:** Transform existing types by iterating over their properties.

```typescript
type Readonly<T> = { readonly [P in keyof T]: T[P]; };
type Partial<T> = { [P in keyof T]?: T[P]; };

// Key remapping with template literals
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

// Filter properties by type
type PickByType<T, U> = {
  [K in keyof T as T[K] extends U ? K : never]: T[K];
};
```

### 4. Template Literal Types

**Purpose:** Create string-based types with pattern matching.

```typescript
type EventName = "click" | "focus" | "blur";
type EventHandler = `on${Capitalize<EventName>}`; // "onClick" | "onFocus" | "onBlur"

// Path building for nested objects
type Path<T> = T extends object
  ? { [K in keyof T]: K extends string ? `${K}` | `${K}.${Path<T[K]>}` : never }[keyof T]
  : never;
```

### 5. Utility Types (Built-in)

```typescript
Partial<T>        // All props optional
Required<T>       // All props required
Readonly<T>       // All props readonly
Pick<T, K>        // Select specific props
Omit<T, K>        // Remove specific props
Exclude<T, U>     // Exclude from union: Exclude<"a"|"b"|"c", "a"> → "b"|"c"
Extract<T, U>     // Extract from union: Extract<"a"|"b"|"c", "a"|"b"> → "a"|"b"
NonNullable<T>    // Remove null/undefined
Record<K, T>      // Object type with keys K and values T
ReturnType<T>     // Return type of a function
Parameters<T>     // Parameters tuple of a function
```

## Advanced Patterns

### Pattern 1: Type-Safe Event Emitter

Key types:
```typescript
type EventMap = { "user:created": { id: string; name: string }; "user:deleted": { id: string } };

class TypedEventEmitter<T extends Record<string, any>> {
  on<K extends keyof T>(event: K, callback: (data: T[K]) => void): void { /* ... */ }
  emit<K extends keyof T>(event: K, data: T[K]): void { /* ... */ }
}
```

### Pattern 2: Type-Safe API Client

```typescript
type ExtractResponse<T> = T extends { response: infer R } ? R : never;

// Usage ensures correct types per endpoint + method
const users = await api.request("/users", "GET"); // → User[]
```

### Pattern 3: Builder Pattern

```typescript
type RequiredKeys<T> = { [K in keyof T]-?: {} extends Pick<T, K> ? never : K }[keyof T];
// build() only available once all required fields are set via conditional overload
```

### Pattern 4: Deep Readonly / Partial

```typescript
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object
    ? T[P] extends Function ? T[P] : DeepReadonly<T[P]>
    : T[P];
};

type DeepPartial<T> = {
  [P in keyof T]?: T[P] extends object
    ? T[P] extends Array<infer U> ? Array<DeepPartial<U>> : DeepPartial<T[P]>
    : T[P];
};
```

### Pattern 5: Type-Safe Form Validation

```typescript
type ValidationRule<T> = { validate: (value: T) => boolean; message: string };
type FieldValidation<T> = { [K in keyof T]?: ValidationRule<T[K]>[] };
type ValidationErrors<T> = { [K in keyof T]?: string[] };
// FormValidator<T> runs rules and returns ValidationErrors<T> | null
```

### Pattern 6: Discriminated Unions (Full Example)

```typescript
type AsyncState<T> =
  | { status: "success"; data: T }
  | { status: "error"; error: string }
  | { status: "loading" };

function handleState<T>(state: AsyncState<T>): void {
  switch (state.status) {
    case "success": console.log(state.data); break;   // Type: T
    case "error":   console.log(state.error); break;  // Type: string
    case "loading": console.log("Loading..."); break;
  }
}

// Type-safe state machine
type AppState =
  | { type: "idle" }
  | { type: "fetching"; requestId: string }
  | { type: "success"; data: unknown }
  | { type: "error"; error: Error };

type AppEvent =
  | { type: "FETCH"; requestId: string }
  | { type: "SUCCESS"; data: unknown }
  | { type: "ERROR"; error: Error }
  | { type: "RESET" };

function reducer(state: AppState, event: AppEvent): AppState {
  switch (state.type) {
    case "idle":
      return event.type === "FETCH"
        ? { type: "fetching", requestId: event.requestId } : state;
    case "fetching":
      if (event.type === "SUCCESS") return { type: "success", data: event.data };
      if (event.type === "ERROR")   return { type: "error", error: event.error };
      return state;
    case "success":
    case "error":
      return event.type === "RESET" ? { type: "idle" } : state;
  }
}
```

## Type Inference Techniques

### infer Keyword

```typescript
type ElementType<T> = T extends (infer U)[] ? U : never;
type PromiseType<T> = T extends Promise<infer U> ? U : never;
type Parameters<T> = T extends (...args: infer P) => any ? P : never;
```

### Type Guards

```typescript
function isString(value: unknown): value is string {
  return typeof value === "string";
}

function isArrayOf<T>(value: unknown, guard: (item: unknown) => item is T): value is T[] {
  return Array.isArray(value) && value.every(guard);
}
```

### Assertion Functions

```typescript
function assertIsString(value: unknown): asserts value is string {
  if (typeof value !== "string") throw new Error("Not a string");
}
```

## Error Handling

| Error | Cause | Solution |
|-------|-------|----------|
| `Type 'X' is not assignable to type 'Y'` | Wrong type passed to generic or function | Check expected type; use type guard or assertion |
| `Property does not exist on type 'never'` | Conditional type resolved to `never` | Check extends clause; union may be exhausted |
| `Type instantiation is excessively deep` | Recursive type hitting TS depth limit | Add base case; use `& {}` to break recursion; limit depth |
| `Object is possibly 'null'` | `strictNullChecks` enabled, value not narrowed | Use optional chaining `?.`, nullish coalescing `??`, or type guard |
| `Cannot find name 'infer'` | `infer` used outside conditional type | Move `infer` inside `extends` clause of conditional type |
| `Argument of type 'unknown' is not assignable` | Using `unknown` without narrowing | Add `typeof` check or type guard before use |

## Best Practices

1. **Use `unknown` over `any`** — enforce type checking at call site
2. **Prefer `interface` for object shapes** — better error messages and merging
3. **Use `type` for unions and complex types** — more flexible
4. **Leverage type inference** — let TypeScript infer when obvious
5. **Put critical instructions FIRST** — complex types: define base cases before recursive
6. **Use strict mode** — enable all strict compiler options in tsconfig.json
7. **Avoid type assertions (`as`)** — use type guards instead
8. **Test your types** — use `type AssertEqual<T,U>` for type-level unit tests

## Common Pitfalls

1. **Over-using `any`** — defeats TypeScript's purpose
2. **Ignoring strict null checks** — runtime errors from unguarded nulls
3. **Overly complex types** — slows compilation; simplify when possible
4. **Circular type references** — can cause compiler errors; use lazy evaluation
5. **Forgetting readonly** — allows unintended mutations in mapped types
6. **Not handling edge cases** — empty arrays, null values, undefined keys

## Resources

- **TypeScript Handbook**: https://www.typescriptlang.org/docs/handbook/
- **Type Challenges**: https://github.com/type-challenges/type-challenges
- **TypeScript Deep Dive**: https://basarat.gitbook.io/typescript/
- **Effective TypeScript**: Book by Dan Vanderkam
