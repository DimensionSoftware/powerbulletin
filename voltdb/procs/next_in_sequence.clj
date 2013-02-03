(ns next-in-sequence)
(require 'u)

(defn statements []
  {"next-in-sequence-select"
     (u/stmt "SELECT nextval FROM sequences WHERE name=?")
   "next-in-sequence-init"
     (u/stmt "INSERT INTO sequences (name, nextval) VALUES (?, 2)")
   "next-in-sequence-incr"
     (u/stmt "UPDATE sequences SET nextval=nextval+1 WHERE name=?")})

(defn run [this name]
  ; upsert next long in sequence
  (u/queue this "next-in-sequence-select" name)
  (let [res1 (nth (u/execute this) 0)]
    (if (< (.getRowCount res1) 1)
      (do (u/queue this "next-in-sequence-init" name)
          (u/execute this)
          1)
      (do (u/queue this "next-in-sequence-incr" name)
          (u/execute this)
          (.getLong (.fetchRow res1 0) 0)))))
