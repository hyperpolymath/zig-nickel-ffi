# SPDX-License-Identifier: MPL-2.0
# Palimpsest: https://github.com/hyperpolymath/palimpsest-license
# zig-nickel-ffi Task Runner

# Default recipe - show help
default:
    @just --list

# ============================================================================
# BUILD
# ============================================================================

# Build the Rust shim
shim:
    cd shim && cargo build --release

# Build Zig libraries (requires shim first)
build: shim
    zig build

# Build everything from scratch
all: clean shim build
    @echo "Build complete!"

# ============================================================================
# TESTING
# ============================================================================

# Run all tests
test: shim
    zig build test

# ============================================================================
# DEVELOPMENT
# ============================================================================

# Quick rebuild (assumes shim already built)
rebuild:
    zig build

# Check Zig code compiles
check:
    zig build --summary all

# ============================================================================
# CLEANUP
# ============================================================================

# Clean all build artifacts
clean:
    rm -rf zig-out .zig-cache
    cd shim && cargo clean

# Clean only Zig artifacts
clean-zig:
    rm -rf zig-out .zig-cache

# ============================================================================
# RSR COMPLIANCE
# ============================================================================

# Check RSR compliance
rsr-check:
    @echo "Checking RSR compliance..."
    @test -f README.adoc && echo "✓ README.adoc" || echo "✗ README.adoc missing"
    @test -f LICENSE && echo "✓ LICENSE" || echo "✗ LICENSE missing"
    @test -f STATE.scm && echo "✓ STATE.scm" || echo "✗ STATE.scm missing"
    @test -f META.scm && echo "✓ META.scm" || echo "✗ META.scm missing"
    @test -f ECOSYSTEM.scm && echo "✓ ECOSYSTEM.scm" || echo "✗ ECOSYSTEM.scm missing"
    @test -f PROVENANCE.md && echo "✓ PROVENANCE.md" || echo "✗ PROVENANCE.md missing"

# ============================================================================
# INFO
# ============================================================================

# Show library sizes
sizes:
    @ls -lh zig-out/lib/ 2>/dev/null || echo "Build first with: just build"

# Show Nickel version from shim
version: shim build
    @echo "Nickel version in shim: 0.10.x (nickel-lang-core)"
