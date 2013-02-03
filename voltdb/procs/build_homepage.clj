(ns build-homepage)
(require 'u)

(defn statements []
  {"select-homepage-doc"
     (u/stmt "SELECT key FROM docs
              WHERE key='homepage' AND type='misc' LIMIT 1")
   "insert-homepage-doc"
     (u/stmt "INSERT INTO docs (key, type, created, json, index_enabled, index_dirty)
              VALUES ('homepage', 'misc', ?, ?, 0, 0)")
   "update-homepage-doc"
     (u/stmt "UPDATE docs SET updated=?, json=?
              WHERE key='homepage' AND type='misc'")
   "select-top-posts"
     (u/stmt "SELECT * FROM posts
              WHERE parent_id IS NULL
              ORDER BY created DESC
              LIMIT 10")})

(defn run [this now]
  (u/queue this "select-top-posts")
  (let [top-posts-json (.toJSONString (nth (u/execute this) 0))]
    ; upsert homepage doc
    (u/queue this "select-homepage-doc")
    (if (< (.getRowCount (nth (u/execute this) 0)) 1)
      ; "{}" is a stub / placeholder
      (u/queue this "insert-homepage-doc" now top-posts-json)
      (u/queue this "update-homepage-doc" now top-posts-json))
    (u/execute this)))
