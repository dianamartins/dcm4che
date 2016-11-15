package org.dcm4che3.tool.storescp;

import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.MasterNotRunningException;
import org.apache.hadoop.hbase.ZooKeeperConnectionException;
import org.apache.hadoop.hbase.client.HTableInterface;
import pt.uminho.haslab.safecloudclient.shareclient.SymColTable;


public class SymHBaseStore extends HBaseStore{

  public SymHBaseStore(String file, String storageDir) throws MasterNotRunningException, ZooKeeperConnectionException, IOException {
    super(file, storageDir);
  }

  @Override
  public HTableInterface createTableInterface(Configuration conf, String tableName) throws Exception {
	  return new SymColTable(conf, tableName);
  }
  
}
