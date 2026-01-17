;; SPDX-License-Identifier: MPL-2.0
;; ECOSYSTEM.scm - Project ecosystem positioning

(ecosystem
  ((version . "1.0.0")
   (name . "zig-nickel-ffi")
   (type . "library")
   (purpose . "Zig FFI bindings for Nickel configuration language")
   (position-in-ecosystem . "infrastructure")
   (related-projects
     ((bunsenite . "primary-consumer")
      (nickel-lang-core . "upstream-dependency")
      (formatrix-docs . "potential-consumer")
      (zig-ffmpeg-ffi . "sibling-ffi")
      (zig-systemd-ffi . "sibling-ffi")
      (zig-cue-ffi . "sibling-ffi")))
   (what-this-is . ("Zig bindings for Nickel evaluation"
                    "C ABI exports for other languages"
                    "Type-checking interface"))
   (what-this-is-not . ("A Nickel implementation"
                        "A configuration management system"))))
