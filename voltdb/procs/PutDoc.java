import org.voltdb.*;

@ProcInfo (
  partitionInfo = "docs.key: 1",
  singlePartition = true
)

public class PutDoc extends VoltProcedure {
  public final SQLStmt selectSQL =
    new SQLStmt( "SELECT json FROM docs WHERE type=? AND key=?");

  public final SQLStmt insertSQL =
    new SQLStmt( "INSERT INTO docs (type, key, json, index_enabled, index_dirty) "
               + "VALUES (?, ?, ?, ?, ?)" );

  public final SQLStmt updateSQL =
    new SQLStmt( "UPDATE docs SET json=?, index_enabled=?, index_dirty=? "
               + "WHERE type=? AND key=?" );

  public VoltTable[] run(String type, String key, String json, long index_enabled) {
    voltQueueSQL(selectSQL, type, key);
    VoltTable res1 = voltExecuteSQL()[0];

    if(res1.getRowCount() < 1) {
      voltQueueSQL(insertSQL, type, key, json, index_enabled, index_enabled);
    }
    else {
      voltQueueSQL(updateSQL, json, index_enabled, index_enabled, type, key);
    }

    return voltExecuteSQL();
  }
}
