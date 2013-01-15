import org.voltdb.*;
import utils.*;

public class AddPost extends VoltProcedure {
  public final SQLStmt insertPost =
    new SQLStmt( "INSERT INTO posts (id, user_id, title, body)"
               + "  VALUES (?, ?, ?, ?)");

  public final SQLStmt insertPostDoc =
    new SQLStmt( "INSERT INTO docs (key, type, json, index_enabled, index_dirty)"
               + "  VALUES (?, 'post', ?, 1, 1)");

  // TODO needs to populate a docs field of type 'post' with no comments (its a new post after all)
  // a post may have the comments in the same blob for perf.. maybe the top comments?
  public VoltTable[] run() {
    // XXX need to setup sequences table to gen key for posts table
    // XXX need to actually have this do the real thing and not just stub
    voltQueueSQL(insertPost, 1, 1, "test title", "test body");
    // need to serialize real json from parameters here
    voltQueueSQL(insertPostDoc, "1", "{title: 'test title', body: 'test body'}");
    return common.test(voltExecuteSQL());
  }
}
