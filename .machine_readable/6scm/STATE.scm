;; SPDX-License-Identifier: MPL-2.0
;; STATE.scm - Project state for zig-nickel-ffi

(state
  (metadata
    (version "0.1.0")
    (schema-version "1.0")
    (created "2025-01-03")
    (updated "2025-01-03")
    (project "zig-nickel-ffi")
    (repo "hyperpolymath/zig-nickel-ffi"))

  (project-context
    (name "zig-nickel-ffi")
    (tagline "Zig FFI bindings for Nickel configuration language")
    (tech-stack "Zig" "Rust" "Nickel" "nickel-lang-core"))

  (current-position
    (phase "functional")
    (overall-completion 80)
    (components
      (rust-shim 90)
      (zig-bindings 85)
      (c-header 100)
      (c-ffi-exports 80)
      (tests 70)
      (documentation 90)))

  (route-to-mvp
    (milestone "v0.1.0 - Core Functionality"
      (items
        ("Rust shim with C exports" done)
        ("Zig bindings via @cImport" done)
        ("Context creation/destruction" done)
        ("Nickel evaluation" done)
        ("Type checking" done)
        ("C FFI re-exports from Zig" done)
        ("Unit tests" done)
        ("README documentation" done))))

  (critical-next-actions
    (immediate
      ("Test with more complex Nickel code")
      ("Add error message retrieval"))))
