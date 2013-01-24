(ns procs.select-users
  (:gen-class
   :extends org.voltdb.VoltProcedure
   :state state
   :init init
   :methods [[run [] org.voltdb.VoltTable]
             [statements [] java.util.Map]]))
 
(defn stmt
  [sql & args]
  (new org.voltdb.SQLStmt sql args))

(defn init-stmts
  []
  {"select" (stmt "SELECT * FROM users")})

(defn -init
  []
  [[] (init-stmts)])

(defn -run
  [this]
  (.voltQueueSQL this (get (.state this) "select") (into-array []))
  (.voltExecuteSQL this))

(defn -statements
  [this]
  (.state this))
