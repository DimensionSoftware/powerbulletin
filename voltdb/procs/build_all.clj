(require 'build-homepage)
(require 'u)

; build all denormalized docs (presumably after tables are bulk-loaded with csv)
(defproc build-all
  [] long
  [this]
  (build-homepage/statements)
  (build-homepage/run this (u/now this))
  1)
