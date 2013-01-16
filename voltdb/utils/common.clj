(ns utils.common
  (:gen-class
   :methods [#^{:static true} [test ["[Lorg.voltdb.VoltTable;"] "[Lorg.voltdb.VoltTable;"]
             #^{:static true} [obj2json [Object] String]]))
 
(defn -test
  [vt]
  vt)

(defn -obj2json
  [obj]
  (.writeValueAsString (new com.fasterxml.jackson.databind.ObjectMapper) obj))
