# Provenance

## Purpose

Direct Zig FFI bindings to the Nickel configuration language (nickel-lang).

Unlike bunsenite (which embeds Nickel in a larger system), this provides standalone FFI access to Nickel's evaluation engine for any project.

## Architecture

Since Nickel is written in Rust without C bindings, this project uses a two-layer approach:

1. **Rust shim** (`shim/`): A small Rust library that wraps `nickel-lang-core` and exposes C-compatible functions
2. **Zig bindings** (`src/`): Zig code that imports the C header and provides a clean Zig API

```
Application → Zig API → C FFI → Rust shim → nickel-lang-core
```

## Use Cases

- Evaluate Nickel configurations from Zig programs
- Embed Nickel scripting in applications
- Type-check Nickel files programmatically
- Use Nickel from any language with C FFI support

## Difference from bunsenite

| Aspect | bunsenite | zig-nickel-ffi |
|--------|-----------|----------------|
| Purpose | Complete Nickel-in-Zig system | Standalone FFI bindings |
| Scope | Full ecosystem | Just evaluation/typecheck |
| Dependencies | Self-contained | Requires nickel-lang-core |
| Use case | Projects using bunsenite | Any project needing Nickel |
