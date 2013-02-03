(require 'defproc)

(defproc select-user
  [long] org.voltdb.VoltTable
  [this & args]
  {"select" (stmt "SELECT * FROM users WHERE id=? LIMIT 1")}

  (.voltQueueSQL this (get-stmt this "select") (into-array args))
  (nth (.voltExecuteSQL this) 0))

;(println (macroexpand '(defproc select-user)))
