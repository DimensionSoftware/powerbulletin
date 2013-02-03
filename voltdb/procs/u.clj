(ns u)

(defn obj2json
  [obj]
  (.writeValueAsString (new com.fasterxml.jackson.databind.ObjectMapper) obj))

(defn foo [x] x)

(defn stmt [sql & args]
         (new org.voltdb.SQLStmt sql args))

(defn get-stmt [this name]
  (get (.state this) name))

(defn queue [this stmtname & args]
  (.voltQueueSQL this (get-stmt this stmtname) (into-array Object args)))

(defn execute [this]
  (.voltExecuteSQL this))

(defn execute-final [this]
  (.voltExecuteSQL this true))
