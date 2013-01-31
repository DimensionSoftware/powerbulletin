(require 'defproc)

(defproc add-post2
  [long long String String] [this id user-id title body]
  {"insert-post"
     (stmt "INSERT INTO posts (id, created, user_id, title, body)
            VALUES (?, ?, ?, ?, ?)")
   "select-homepage-doc"
     (stmt "SELECT key FROM docs
            WHERE key='homepage' AND type='misc' LIMIT 1")
   "insert-homepage-doc"
     (stmt "INSERT INTO docs (key, type, created, json, index_enabled, index_dirty)
            VALUES ('homepage', 'misc', ?, ?, 0, 0)")
   "update-homepage-doc"
     (stmt "UPDATE docs SET updated=?, json=?
            WHERE key='homepage' AND type='misc'")
   "select-top-posts"
     (stmt "SELECT * FROM posts
            WHERE parent_id IS NULL
            ORDER BY created DESC
            LIMIT 10")}

  (let [now (new java.util.Date)]
    (queue this "insert-post" id now user-id title body)
    (queue this "select-top-posts")
    (let [top-posts-json (.toJSONString (nth (execute this) 1))]
      ; upsert homepage doc
      (queue this "select-homepage-doc")
      (if (< (.getRowCount (nth (execute this) 0)) 1)
        ; "{}" is a stub / placeholder
        (queue this "insert-homepage-doc" now top-posts-json)
        (queue this "update-homepage-doc" now top-posts-json))

      (nth (execute-final this) 0))))
