// SPDX-License-Identifier: AGPL-3.0-or-later
// C header for nickel-ffi-shim

#ifndef NICKEL_FFI_H
#define NICKEL_FFI_H

#ifdef __cplusplus
extern "C" {
#endif

// Opaque context handle
typedef struct NickelContext NickelContext;

// Initialize a new Nickel context
NickelContext* nickel_context_new(void);

// Free a Nickel context
void nickel_context_free(NickelContext* ctx);

// Evaluate Nickel source code and return JSON result
// Returns NULL on error, caller must free with nickel_string_free
char* nickel_eval(NickelContext* ctx, const char* source);

// Type-check Nickel source code
// Returns 1 if valid, 0 if invalid or error
int nickel_typecheck(NickelContext* ctx, const char* source);

// Free a string returned by nickel_eval
void nickel_string_free(char* s);

// Get the Nickel version
const char* nickel_version(void);

#ifdef __cplusplus
}
#endif

#endif // NICKEL_FFI_H
