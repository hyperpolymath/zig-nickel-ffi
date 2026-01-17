;; SPDX-License-Identifier: MPL-2.0
;; META.scm - Project metadata and architectural decisions

(define project-meta
  `((version . "1.0.0")
    (architecture-decisions
      ((adr-001
        (status . "accepted")
        (date . "2025-01-03")
        (context . "Need FFI bindings for Nickel from Zig")
        (decision . "Use Rust shim wrapping nickel-lang-core, expose C ABI, Zig declares externs directly")
        (consequences . "No C code needed, clean architecture, Zig 0.15 compatible"))))
    (development-practices
      ((code-style . "zig-fmt")
       (security . "openssf-scorecard")
       (testing . "zig-test")
       (versioning . "semver")
       (documentation . "asciidoc")
       (branching . "trunk-based")))
    (design-rationale
      ((no-c-header . "Zig can declare extern C functions directly, eliminating C header maintenance")
       (rust-shim . "nickel-lang-core is Rust-only, shim provides C ABI exports")))))
