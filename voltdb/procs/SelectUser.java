import org.voltdb.*;

public class SelectUser extends VoltProcedure {
  public final SQLStmt sql =
    new SQLStmt("SELECT * FROM users WHERE id=? ORDER by id LIMIT 1");

  public VoltTable run(long id) {
    voltQueueSQL(sql, id);
    return voltExecuteSQL()[0];
  }
}
