(ns u)

(defn obj2json ^String [^Object obj]
  (.writeValueAsString (new com.fasterxml.jackson.databind.ObjectMapper) obj))

(defn json2obj ^java.util.Map [^String json]
  (.readValue (new com.fasterxml.jackson.databind.ObjectMapper) json java.util.Map))

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

; custom json format for our purposes
; vt = org.voltdb.VoltTable
(defn vt2json ^String [^org.voltdb.VoltTable vt]
  (let [vtobj (json2obj (.toJSONString vt))
        vtcols (map (fn [c] (clojure.string/lower-case (get c "name"))) (get vtobj "schema"))
        vtrows (get vtobj "data")
        out (map (fn [r] (zipmap vtcols r)) vtrows)]
    (obj2json out)))
