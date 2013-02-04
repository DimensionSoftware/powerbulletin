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


(defn user-stub []
  {"id" 1
   "name" "intrepid_codergirl"
   "created_at" (new java.util.Date)})

(defn sub-post-stub [id]
  {"id" id
   "title" (str "Sub-Post Title " id)
   "date" (new java.util.Date)
   "body" "hello world from a stub post yo"
   "user" (user-stub)})

(defn post-stub [id]
  {"id" id
   "title" (str "Post Title " id)
   "date" (new java.util.Date)
   "body" "hello world"
   "user" (user-stub)
   "subposts" (map sub-post-stub (range 1 3))})

(defn sub-forum-stub [id]
  {"id" id
   "theme" (if (= id 1) "light" "dark")
   "title" (str "Sub-Forum " id)
   "slug" (str "sub-forum-" id)
   "description" (str "Description for Sub-Forum " id)
   "posts" (map post-stub (range 1 3))})

; depersonalized, non-time-aware for docs
(defn forum-stub [id]
  {"id" id
   "theme" (if (= id 1) "light" "dark")
   "title" (str "Forum " id)
   "slug" (str "forum-" id)
   "description" (str "Description for Forum " id)
   "posts" (map post-stub (range 1 3))
   "subforums" (map sub-forum-stub (range 1 3))})

(defn homepage-stub []
  {"forums" (map forum-stub (range 1 4))})

(defn run [this now]
  (u/queue this "build-homepage-top-posts")
  ; TODO: additionally, queue up other queries needed to populate homepage data
  ; including, but not limited to:
  ; - toplevel forums
  ; - first level of subforums for each toplevel forum
  ; - what else guys??
  ; XXX: REALLY use top-posts, not just pretend ; )
  (let [top-posts (u/vt2maplist (nth (u/execute this) 0))
        homepage (homepage-stub)
        out (u/obj2json homepage)]
    (println out)
    ; upsert homepage doc
    (u/queue this "build-homepage-select")
    (if (< (.getRowCount (nth (u/execute this) 0)) 1)
      ; "{}" is a stub / placeholder
      (u/queue this "build-homepage-insert" now out)
      (u/queue this "build-homepage-update" now out))
    (u/execute this)))
