(ns build-homepage)
(require 'u)

(defn statements []
  {"build-homepage-select"
     (u/stmt "SELECT key FROM docs
              WHERE key='homepage' AND type='misc' LIMIT 1")
   "build-homepage-insert"
     (u/stmt "INSERT INTO docs (key, type, created, json, index_enabled, index_dirty)
              VALUES ('homepage', 'misc', ?, ?, 0, 0)")
   "build-homepage-update"
     (u/stmt "UPDATE docs SET updated=?, json=?
              WHERE key='homepage' AND type='misc'")
   "build-homepage-top-posts"
     (u/stmt "SELECT * FROM posts
              WHERE parent_id IS NULL
              ORDER BY created DESC, id DESC
              LIMIT 10")})

(defn run [this now]
  (u/queue this "build-homepage-top-posts")
  ; TODO: additionally, queue up other queries needed to populate homepage data
  ; including, but not limited to:
  ; - toplevel forums
  ; - first level of subforums for each toplevel forum
  ; - what else guys??
  (let [top-posts (u/vt2maplist (nth (u/execute this) 0))
        out (u/obj2json top-posts)]
    (println out)
    ; upsert homepage doc
    (u/queue this "build-homepage-select")
    (if (< (.getRowCount (nth (u/execute this) 0)) 1)
      ; "{}" is a stub / placeholder
      (u/queue this "build-homepage-insert" now out)
      (u/queue this "build-homepage-update" now out))
    (u/execute this)))
