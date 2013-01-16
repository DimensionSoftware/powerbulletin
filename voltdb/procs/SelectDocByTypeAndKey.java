import org.voltdb.*;

@ProcInfo (
  partitionInfo = "docs.key: 1",
  singlePartition = true
)

public class SelectDocByTypeAndKey extends VoltProcedure {
  public final SQLStmt sql =
    new SQLStmt("SELECT json FROM docs WHERE type=? AND key=? LIMIT 1");

  public VoltTable run(String type, String key) {
    voltQueueSQL(sql, type, key);
    return voltExecuteSQL()[0];
  }
}
