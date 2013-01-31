(require 'defproc)

(defproc add-post2
  [long long String String] [this id user-id title body]
  {"insert-post"
     (stmt "INSERT INTO posts (id, user_id, title, body)
            VALUES (?, ?, ?, ?)")
   "select-homepage-doc"
     (stmt "SELECT key FROM docs
            WHERE key='homepage' AND type='misc' LIMIT 1")
   "insert-homepage-doc"
     (stmt "INSERT INTO docs (key, type, json, index_enabled, index_dirty)
            VALUES ('homepage', 'misc', ?, 0, 0)")
   "update-homepage-doc"
     (stmt "UPDATE docs SET json=?
            WHERE key='homepage' AND type='misc'")}

  (queue this "select-homepage-doc")
  (if (< (.getRowCount (nth (.voltExecuteSQL this) 0)) 1)
    ; "{}" is a stub / placeholder
    (queue this "insert-homepage-doc" "{}")
    (queue this "update-homepage-doc" "{}"))
  (queue this "insert-post" id user-id title body)
  (nth (execute this true) 0))
