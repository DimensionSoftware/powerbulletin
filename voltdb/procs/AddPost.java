import org.voltdb.*;
import utils.*;
import java.util.*;

public class AddPost extends VoltProcedure {
  public final SQLStmt insertPostSQL =
    new SQLStmt( "INSERT INTO posts (id, user_id, title, body)"
               + "  VALUES (?, ?, ?, ?)");

  public final SQLStmt insertPostDocSQL =
    new SQLStmt( "INSERT INTO docs (key, type, json, index_enabled, index_dirty)"
               + "  VALUES (?, 'post', ?, 1, 1)");

  public VoltTable[] run(long user_id, String title, String body) {
    // XXX need to setup sequences table to gen key for posts table
    voltQueueSQL(insertPostSQL, 1, user_id, title, body);
    Map<String,Object> post = new HashMap<String,Object>();
    post.put("title", title);
    post.put("body", body);
    voltQueueSQL(insertPostDocSQL, "1", common.obj2json(post));
    return voltExecuteSQL();
  }
}
