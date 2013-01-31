(ns u)

(defn obj2json
  [obj]
  (.writeValueAsString (new com.fasterxml.jackson.databind.ObjectMapper) obj))

(defn foo [x] x)
