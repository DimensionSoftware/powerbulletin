(require 'build-homepage)
(require 'defproc)
(require 'u)

(defproc add-post2
  [long long String String] [this id user-id title body]
  (merge (build-homepage/statements)
    {"insert-post"
       (stmt "INSERT INTO posts (id, created, user_id, title, body)
              VALUES (?, ?, ?, ?, ?)")})

  (let [now (new java.util.Date)]
    (u/queue this "insert-post" id now user-id title body)
    (u/execute this)
    (nth (build-homepage/run this now) 0)))
