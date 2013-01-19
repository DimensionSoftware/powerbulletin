CREATE TABLE sequences (
  name    VARCHAR(64) NOT NULL,
  nextval BIGINT NOT NULL,
  PRIMARY KEY(name)
);
PARTITION TABLE sequences ON COLUMN name;

CREATE TABLE users (
  id    BIGINT NOT NULL,
  login VARCHAR(32) NOT NULL,
  PRIMARY KEY (id)
);
PARTITION TABLE users ON COLUMN id;

CREATE TABLE comments (
  id        BIGINT NOT NULL,
  parent_id BIGINT,
  user_id   BIGINT NOT NULL,
  post_id   BIGINT NOT NULL,
  body      VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id)
);
PARTITION TABLE comments ON COLUMN post_id;

CREATE TABLE posts ( 
  id      BIGINT NOT NULL,
  user_id BIGINT NOT NULL,
  title   VARCHAR(64) NOT NULL,
  body    VARCHAR(1000) NOT NULL,
  PRIMARY KEY (id)
);
PARTITION TABLE posts ON COLUMN id;

CREATE TABLE docs (
  key           VARCHAR(100) NOT NULL,
  type          VARCHAR(100) NOT NULL,
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
CREATE PROCEDURE FROM CLASS AddPost;
CREATE PROCEDURE FROM CLASS NextInSequence;
CREATE PROCEDURE FROM CLASS GetDoc;
CREATE PROCEDURE FROM CLASS PutDoc;
