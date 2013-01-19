import org.voltdb.*;
import utils.*;
import java.util.*;

@ProcInfo (
  singlePartition = false
)

public class AddPost extends VoltProcedure {
  public final SQLStmt insertPostSQL =
    new SQLStmt( "INSERT INTO posts (id, user_id, title, body)"
               + "  VALUES (?, ?, ?, ?)");

  public final SQLStmt insertPostDocSQL =
    new SQLStmt( "INSERT INTO docs (key, type, json, index_enabled, index_dirty)"
               + "  VALUES (?, 'post', ?, 1, 1)");

  public VoltTable run(long id, long user_id, String title, String body) {
    voltQueueSQL(insertPostSQL, id, user_id, title, body);
    Map<String,Object> post = new HashMap<String,Object>();
    post.put("id", id);
    post.put("title", title);
    post.put("body", body);
    voltQueueSQL(insertPostDocSQL, Long.toString(id), common.obj2json(post));
    return voltExecuteSQL()[0];
  }
}
