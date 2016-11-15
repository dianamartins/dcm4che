package org.dcm4che3.tool.storescp;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.MasterNotRunningException;
import org.apache.hadoop.hbase.ZooKeeperConnectionException;
import org.apache.hadoop.hbase.client.HTable;
import org.apache.hadoop.hbase.client.HTableInterface;

public class DefaultHBaseStore extends HBaseStore{

	public DefaultHBaseStore(String file, String storageDir) throws MasterNotRunningException, ZooKeeperConnectionException, IOException {
		super(file,storageDir);
	}

	@Override
	public HTableInterface createTableInterface(Configuration conf, String tableName) throws Exception {
		return new HTable(conf, tableName);		
	}
}
