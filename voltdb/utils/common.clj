(ns utils.common
  (:gen-class
   :methods [#^{:static true} [test ["[Lorg.voltdb.VoltTable;"] "[Lorg.voltdb.VoltTable;"]]))
 
(defn -test
  [vt]
  vt)
