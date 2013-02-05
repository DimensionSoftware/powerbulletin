(ns build-forum)
(require 'u)

(defn statements []
  {"build-forum-select"
     (u/stmt "SELECT key FROM docs
              WHERE key='forum' AND type='misc' LIMIT 1")
   "build-forum-insert"
     (u/stmt "INSERT INTO docs (key, type, created, json, index_enabled, index_dirty)
              VALUES ('forum', 'misc', ?, ?, 0, 0)")
   "build-forum-update"
     (u/stmt "UPDATE docs SET updated=?, json=?
              WHERE key='forum' AND type='misc'")
   "build-forum-top-posts"
     (u/stmt "SELECT p.*, a.name user_name
              FROM posts p, aliases a
              WHERE a.user_id=p.user_id
                AND a.site_id='cats.pb.com'
                AND p.parent_id IS NULL
                AND p.forum_id=?
              ORDER BY created DESC, id DESC")
   "build-forum-sub-posts"
     (u/stmt "SELECT p.*, a.name user_name
              FROM posts p, aliases a
              WHERE a.user_id=p.user_id
                AND a.site_id='cats.pb.com'
                AND p.parent_id=?
              ORDER BY created DESC, id DESC") ; site='cats.pb.com' is a STUB eventually sites dynamic too... alias based on site...
   "build-forum"
     (u/stmt "SELECT * FROM forums
              WHERE id=?")})

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

; recursively gets the post tree, starting with toplevel posts in a forum
; this should return a list of posts
(defn get-post-tree [this parent-post-id]
  (let [vtposts (u/qe this "build-homepage-sub-posts" parent-post-id)]
    (if (< (.getRowCount vtposts) 1)
      []
      (let [posts (u/vt2maplist vtposts)]
        (map (fn [post] (assoc post "posts" (get-post-tree this (get post "id")))) posts)))))

(defn run [this now forum-id]
  ; XXX: eventually we parameterize on site too
  (let [topforum (u/vt2maplist (u/qe this "build-forum" forum-id))]
    ; queue up top posts for each topforum
    (dorun (map (fn [forum] (u/queue this "build-forum-top-posts" (get forum "id"))) topforum))

    (let [topposts (doall (map u/vt2maplist (u/execute this)))
          topposts (doall (map (fn [post] (get-post-tree this (get post "id"))) topposts))
          topforum (doall (map-indexed (fn [i forum] (assoc (into {} forum) "posts" (nth topposts i))) topforum))]

      ; XXX: REALLY use top-posts, not just pretend ; )
      (let [topforum {"forums" topforum}
            out (u/obj2json topforum)]
        ; upsert forum doc
        (if (< (.getRowCount (u/qe this "build-forum-select")) 1)
          ; "{}" is a stub / placeholder
          (u/queue this "build-forum-insert" now out)
          (u/queue this "build-forum-update" now out))
        (u/execute this)))))
