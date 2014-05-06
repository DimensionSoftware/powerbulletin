# This is prep for db.pages.soft-delete and db.forums.soft-delete.
# pages.path and forums.uri need to be nullable but unique.
# forums.uri was already that way, but pages.path needed to be changed.
# forums.config was also added so we would have a place to store meta-data about the soft-delete.
# This will help us restore later if we need to.

@up = (pg, cb) ->
  alters-sql = """
  ALTER TABLE pages ALTER path DROP NOT NULL;
  ALTER TABLE forums ADD COLUMN config JSON NOT NULL DEFAULT '{}';
  """
  pg.query alters-sql, [], cb
