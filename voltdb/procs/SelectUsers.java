import org.voltdb.*;

public class SelectUsers extends VoltProcedure {
  public final SQLStmt sql =
    new SQLStmt("SELECT * FROM users");

  public VoltTable[] run() {
    voltQueueSQL(sql);
    return voltExecuteSQL();
  }
}
