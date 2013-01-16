import org.voltdb.*;

@ProcInfo (
  partitionInfo = "sequences.name: 0",
  singlePartition = true
)

public class NextInSequence extends VoltProcedure {
  public final SQLStmt selectSQL =
    new SQLStmt( "SELECT nextval FROM sequences WHERE name=?");

  public final SQLStmt initSQL =
    new SQLStmt( "INSERT INTO sequences (name, nextval) VALUES (?, 2)");

  public final SQLStmt incrementSQL =
    new SQLStmt( "UPDATE sequences SET nextval=nextval+1 WHERE name=?");

  public long run(String name) {
    voltQueueSQL(selectSQL, name);
    VoltTable res1 = voltExecuteSQL()[0];

    if(res1.getRowCount() < 1) {
      voltQueueSQL(initSQL, name);
      voltExecuteSQL();
      return 1;
    }
    else {
      voltQueueSQL(incrementSQL, name);
      voltExecuteSQL();
      return res1.fetchRow(0).getLong(0);
    }
  }
}
