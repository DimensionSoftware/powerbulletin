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

     (defn ~'get-stmt [this# name#]
       (get (.state this#) name#))

     (defn ~'-init []
       [[] ~statements])

     (defn ~'-statements [this#]
       (.state this#))

     (defn ~'-run
       ~params
       ~@body)))
