CREATE TABLE sequences (
  name    VARCHAR(64) NOT NULL,
  nextval BIGINT NOT NULL,
  PRIMARY KEY(name)
);
PARTITION TABLE sequences ON COLUMN name;

-- site has many forums
-- site belongs to user (if they are an admin)
-- NOTE: id is the base domain (string)
CREATE TABLE sites (
  id      VARCHAR(256) NOT NULL,
  user_id BIGINT NOT NULL,
  created TIMESTAMP NOT NULL,
  PRIMARY KEY (id)
);
PARTITION TABLE sites ON COLUMN id;

-- forum has many posts
-- forum has many child forums
-- if a forum does not have a parent, then it is a top-level category
-- if a forum does not have a parent, then it cannot have posts
CREATE TABLE forums (
  id          BIGINT NOT NULL,
  parent_id   BIGINT,
  site_id     VARCHAR(256) NOT NULL,
  created     TIMESTAMP NOT NULL,
  title       VARCHAR(256) NOT NULL,
  slug        VARCHAR(256) NOT NULL,
  description VARCHAR(1024) NOT NULL,
  media_url   VARCHAR(1024),
  PRIMARY KEY (id)
);
--PARTITION TABLE forums ON COLUMN site_id;
CREATE INDEX forums_site ON forums (parent_id, site_id);
CREATE UNIQUE INDEX forums_sort ON forums (created DESC, id DESC);

-- user has many auths
-- user has many aliases
-- user has many sites (if they are admin)
-- user has many posts
CREATE TABLE users (
  id BIGINT NOT NULL,
  created TIMESTAMP NOT NULL,
  PRIMARY KEY (id)
);

-- alias belongs to user
CREATE TABLE aliases (
  user_id BIGINT NOT NULL,
  site_id VARCHAR(256) NOT NULL,
  created TIMESTAMP NOT NULL,
  name    VARCHAR(64) NOT NULL,
  PRIMARY KEY (user_id, site_id)
);

-- auth belongs to user
CREATE TABLE auths (
  user_id BIGINT NOT NULL,
  type    VARCHAR(16),
  created TIMESTAMP NOT NULL,
  json    VARCHAR(1024),
  PRIMARY KEY (user_id, type)
);

-- post has many child posts
-- post belongs to user
-- post belongs to forum
CREATE TABLE posts ( 
  id        BIGINT NOT NULL,
  parent_id BIGINT,
  user_id   BIGINT NOT NULL,
  forum_id  BIGINT NOT NULL,
  created   TIMESTAMP NOT NULL,
  title     VARCHAR(256) NOT NULL,
  body      VARCHAR(1024) NOT NULL,
  PRIMARY KEY (id)
);
PARTITION TABLE posts ON COLUMN id;
CREATE UNIQUE INDEX sort1 ON posts (created DESC, id DESC);

CREATE TABLE docs (
  key           VARCHAR(64) NOT NULL,
  type          VARCHAR(64) NOT NULL,
  created       TIMESTAMP NOT NULL,
  updated       TIMESTAMP,
  json          VARCHAR(1048576) NOT NULL,
  index_enabled TINYINT NOT NULL,
  index_dirty   TINYINT NOT NULL,
  PRIMARY KEY (key, type)
);
PARTITION TABLE docs ON COLUMN key;

-- use this method for defining procedures which are
-- multi-partitioned (not fast), otherwise use real stored
-- procedures which can be marked single-partition
--CREATE PROCEDURE SelectDocByTypeAndKey AS
--  SELECT json FROM docs WHERE type=? AND key=? LIMIT 1;

CREATE PROCEDURE FROM CLASS SelectUser;
--CREATE PROCEDURE FROM CLASS AddPost;
CREATE PROCEDURE FROM CLASS NextInSequence;
CREATE PROCEDURE FROM CLASS GetDoc;
CREATE PROCEDURE FROM CLASS PutDoc;
CREATE PROCEDURE FROM CLASS select_user;
CREATE PROCEDURE FROM CLASS add_post2;
--PARTITION PROCEDURE select_user ON TABLE users COLUMN id;
