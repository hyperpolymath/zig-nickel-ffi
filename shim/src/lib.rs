// SPDX-License-Identifier: AGPL-3.0-or-later
//! C FFI shim for Nickel language
//! This Rust library wraps nickel-lang-core and exposes C-compatible functions

use nickel_lang_core::eval::cache::lazy::CBNCache;
use nickel_lang_core::program::Program;
use nickel_lang_core::typecheck::TypecheckMode;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::ptr;

type NickelProgram = Program<CBNCache>;

/// Opaque handle to Nickel evaluation context
pub struct NickelContext {
    _placeholder: u8,
}

/// Initialize a new Nickel context
#[no_mangle]
pub extern "C" fn nickel_context_new() -> *mut NickelContext {
    let ctx = Box::new(NickelContext { _placeholder: 0 });
    Box::into_raw(ctx)
}

/// Free a Nickel context
#[no_mangle]
pub extern "C" fn nickel_context_free(ctx: *mut NickelContext) {
    if !ctx.is_null() {
        unsafe {
            drop(Box::from_raw(ctx));
        }
    }
}

/// Evaluate Nickel source code and return JSON result
/// Returns null on error, caller must free the result with nickel_string_free
#[no_mangle]
pub extern "C" fn nickel_eval(_ctx: *mut NickelContext, source: *const c_char) -> *mut c_char {
    if source.is_null() {
        return ptr::null_mut();
    }

    let source_str = unsafe {
        match CStr::from_ptr(source).to_str() {
            Ok(s) => s,
            Err(_) => return ptr::null_mut(),
        }
    };

    match eval_source(source_str) {
        Some(result) => match CString::new(result) {
            Ok(cstr) => cstr.into_raw(),
            Err(_) => ptr::null_mut(),
        },
        None => ptr::null_mut(),
    }
}

/// Evaluate Nickel source and return the result as a string
fn eval_source(source: &str) -> Option<String> {
    let mut program: NickelProgram = Program::new_from_source(
        std::io::Cursor::new(source.as_bytes()),
        "<input>",
        std::io::stderr(),
    )
    .ok()?;

    let result = program.eval_full().ok()?;
    Some(format!("{result}"))
}

/// Type-check Nickel source code
/// Returns 1 if valid, 0 if invalid or error
#[no_mangle]
pub extern "C" fn nickel_typecheck(_ctx: *mut NickelContext, source: *const c_char) -> i32 {
    if source.is_null() {
        return 0;
    }

    let source_str = unsafe {
        match CStr::from_ptr(source).to_str() {
            Ok(s) => s,
            Err(_) => return 0,
        }
    };

    if typecheck_source(source_str) {
        1
    } else {
        0
    }
}

/// Type-check Nickel source
fn typecheck_source(source: &str) -> bool {
    let mut program: NickelProgram = match Program::new_from_source(
        std::io::Cursor::new(source.as_bytes()),
        "<input>",
        std::io::stderr(),
    ) {
        Ok(p) => p,
        Err(_) => return false,
    };

    program.typecheck(TypecheckMode::Walk).is_ok()
}

/// Free a string returned by nickel_eval
#[no_mangle]
pub extern "C" fn nickel_string_free(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            drop(CString::from_raw(s));
        }
    }
}

/// Get the Nickel version
#[no_mangle]
pub extern "C" fn nickel_version() -> *const c_char {
    static VERSION: &[u8] = b"0.10.0\0";
    VERSION.as_ptr() as *const c_char
}
