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
            WHERE key='homepage' AND type='misc'")
   }

  (.voltQueueSQL this (get-stmt this "insert-post") (into-array [id user-id title body]))
  (nth (.voltExecuteSQL this) 0))
