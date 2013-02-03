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

  public final SQLStmt selectHomepageDocSQL =
    new SQLStmt( "SELECT key FROM docs WHERE key='homepage' AND type='misc' LIMIT 1");

  public final SQLStmt insertHomepageDocSQL =
    new SQLStmt( "INSERT INTO docs (key, type, json, index_enabled, index_dirty)"
               + "  VALUES ('homepage', 'misc', ?, 0, 0)");

  public final SQLStmt updateHomepageDocSQL =
    new SQLStmt( "UPDATE docs SET json=? WHERE key='homepage' and type='misc'");

  //public final SQLStmt selectHomepagePostsSQL =
  
  // need to use sql statement to generate list of posts before feeding into json
  // splice user data in in controller before rendering jade
  public VoltTable[] run(long id, long user_id, String title, String body) {
    Map<String,Object> post = new HashMap<String,Object>();
    post.put("id", id);
    post.put("title", title);
    post.put("body", body);
    ArrayList<Object> comments = new ArrayList<Object>();
    post.put("posts", comments);
    Map<String,Object> homepage = new HashMap<String,Object>();

    // replace post here with true list of posts
    ArrayList<Object> topics = new ArrayList<Object>();
    topics.add(post);

    homepage.put("topics", topics);

    voltQueueSQL(selectHomepageDocSQL);

    if(voltExecuteSQL()[0].getRowCount() < 1) {
      voltQueueSQL(insertHomepageDocSQL, common.obj2json(homepage));
    }
    else {
      voltQueueSQL(updateHomepageDocSQL, common.obj2json(homepage));
    }

    voltQueueSQL(insertPostSQL, id, user_id, title, body);

    return voltExecuteSQL();
  }
}
