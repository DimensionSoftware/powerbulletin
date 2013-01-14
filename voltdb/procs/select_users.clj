(ns procs.select_users
  (:gen-class
   :extends org.voltdb.VoltProcedure
   :methods [[run [] org.voltdb.VoltTable]]))
 
(defn -run
  [this]
  (.voltQueueSQL this (new org.voltdb.SQLStmt "SELECT * FROM users") (make-array Object 0))
  (.voltExecuteSQL this))
