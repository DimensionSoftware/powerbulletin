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
   "build-homepage-top-posts-for-forum"
     (u/stmt "SELECT * FROM posts
              WHERE parent_id IS NULL AND forum_id=?
              ORDER BY created DESC, id DESC
              LIMIT 10")
   "build-homepage-top-forums-for-site"
     (u/stmt "SELECT * FROM forums
              WHERE parent_id IS NULL AND site_id=?
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

(defn get-posts [fid]
  '(if ))
(defn run [this now]
  ; XXX: eventually we parameterize on site too
  (let [topforums (u/vt2maplist (u/qe this "build-homepage-top-forums-for-site" 1))]
    (dorun (map (fn [forum] (u/queue this "build-homepage-top-posts-for-forum" (get forum "id"))) topforums))
    (println "foo")
    (let [topposts (map u/vt2maplist (u/execute this))
          topforums (map-indexed (fn [i f] (assoc f "posts" (nth topposts i))) topforums)]

      (println "bar")
      ; XXX: REALLY use top-posts, not just pretend ; )
      (let [homepage {"forums" topforums}
            out (u/obj2json homepage)]
        (println topforums)
        ; upsert homepage doc
        (if (< (.getRowCount (u/qe this "build-homepage-select")) 1)
          ; "{}" is a stub / placeholder
          (u/queue this "build-homepage-insert" now out)
          (u/queue this "build-homepage-update" now out))
        (u/execute this)))))
