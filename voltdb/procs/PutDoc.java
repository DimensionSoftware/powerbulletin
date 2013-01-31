import org.voltdb.*;
import java.util.Date;

@ProcInfo (
  partitionInfo = "docs.key: 1",
  singlePartition = true
)

public class PutDoc extends VoltProcedure {
  public final SQLStmt selectSQL =
    new SQLStmt( "SELECT json FROM docs WHERE type=? AND key=?");

  public final SQLStmt insertSQL =
    new SQLStmt( "INSERT INTO docs (type, key, created, json, index_enabled, index_dirty) "
               + "VALUES (?, ?, ?, ?, ?, ?)" );

  public final SQLStmt updateSQL =
    new SQLStmt( "UPDATE docs SET updated=?, json=?, index_enabled=?, index_dirty=? "
               + "WHERE type=? AND key=?" );

  public VoltTable[] run(String type, String key, String json, long index_enabled) {
    voltQueueSQL(selectSQL, type, key);
    VoltTable res1 = voltExecuteSQL()[0];
    Date now = new Date();

    if(res1.getRowCount() < 1) {
      voltQueueSQL(insertSQL, type, key, now, json, index_enabled, index_enabled);
    }
    else {
      voltQueueSQL(updateSQL, now, json, index_enabled, index_enabled, type, key);
    }

    return voltExecuteSQL();
  }
}
