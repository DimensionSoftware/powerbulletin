(ns select-user
  (:gen-class
   :extends org.voltdb.VoltProcedure
   :state state
   :init init
   :methods [[run [long] org.voltdb.VoltTable]
             [statements [] java.util.Map]]))
 
(defn stmt
  [sql & args]
  (new org.voltdb.SQLStmt sql args))

(defn init-stmts
  []
  {"select" (stmt "SELECT * FROM users WHERE id=? LIMIT 1")})

(defn -init
  []
  [[] (init-stmts)])

(defn -run
  [this & args]
  (.voltQueueSQL this (get (.state this) "select") (into-array args))
  (nth (.voltExecuteSQL this) 0))

(defn -statements
  [this]
  (.state this))
