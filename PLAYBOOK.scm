;; SPDX-License-Identifier: MPL-2.0
;; PLAYBOOK.scm - Operational runbook

(define playbook
  `((version . "1.0.0")
    (procedures
      ((build . (("shim" . "just shim")
                 ("zig" . "just build")
                 ("all" . "just all")))
       (test . (("unit" . "just test")))
       (release . (("check" . "just rsr-check")
                   ("tag" . "git tag -a vX.Y.Z")))
       (debug . (("sizes" . "just sizes")
                 ("version" . "just version")))))
    (alerts . ())
    (contacts . ())))
