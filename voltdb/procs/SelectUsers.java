import org.voltdb.*;
import utils.*;

public class SelectUsers extends VoltProcedure {
  public final SQLStmt sql =
    new SQLStmt("SELECT * FROM users ORDER BY id");

  public VoltTable[] run() {
    voltQueueSQL(sql);
    return common.test(voltExecuteSQL());
  }
}
