# typescript-advanced-types

> TypeScript type system reference skill. Covers generics, conditional types, mapped types, template literals, utility types, and type inference patterns.

## Pattern: Tool Wrapper

Loads TypeScript type knowledge on demand. User asks a type question → skill provides guidance, patterns, and working code examples.

## Install

No installation required. Pure knowledge skill — no scripts or external dependencies beyond having TypeScript/Node.js available.

## Usage

Invoke by asking TypeScript type questions naturally:

- "How do I create a DeepReadonly type?"
- "Write a type-safe event emitter"
- "What's the difference between `type` and `interface`?"
- "How do I use the `infer` keyword?"

## Design Decisions

- **Knowledge-only, no scripts**: This skill is a reference guide. Compile-time type checking happens in the user's project via `tsc --noEmit`.
- **Pattern coverage**: Covers 6 advanced patterns (Event Emitter, API Client, Builder, Deep Readonly/Partial, Form Validation, Discriminated Unions) — selected for real-world frequency.
- **Code-first**: Every concept has a runnable TypeScript snippet, not just prose explanation.
- **Strict mode assumed**: All examples are written for `"strict": true` in tsconfig.

## Limitations

- Does not run `tsc` — validation must happen in the user's project.
- Does not generate tsconfig files automatically (ask separately).
- Very deep recursive types (>20 levels) may hit TypeScript compiler limits — noted in Performance section.
- Examples are TypeScript 4.7+ compatible; older versions may lack some features (e.g., template literal types require TS 4.1+).

## Related Skills

- `node-typescript` — Node.js project scaffolding with TypeScript
- `react-advanced` — React + TypeScript patterns
