(ns procs.select-users
  (:gen-class
   :extends org.voltdb.VoltProcedure
   :methods [[run [] org.voltdb.VoltTable]
             [statements [] java.util.Map]]))
 
(defn -run
  [this]
  (.voltQueueSQL this (new org.voltdb.SQLStmt "SELECT * FROM users") (into-array []))
  (.voltExecuteSQL this))

(defn -statements
  [this]
  )
