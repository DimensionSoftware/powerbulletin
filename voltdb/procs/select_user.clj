(defmacro defproc [name param-types params statements & body]
  `(do
     (ns ~name
       (:gen-class
        :extends org.voltdb.VoltProcedure
        :state ~'state
        :init ~'init
        :methods [[~'run ~param-types org.voltdb.VoltTable]
                  [~'statements [] java.util.Map]]))

     (defn ~'stmt [sql# & args#]
       (new org.voltdb.SQLStmt sql# args#))

     (defn ~'-init []
       [[] ~statements])

     (defn ~'-statements [this#]
       (.state this#))

     (defn ~'-run
       ~params
       ~@body)))

(defproc select-user [long] [this & args]
  {"select" (stmt "SELECT * FROM users WHERE id=? LIMIT 1")}

  (.voltQueueSQL this (get (.state this) "select") (into-array args))
  (nth (.voltExecuteSQL this) 0))

;(println (macroexpand '(defproc select-user)))
