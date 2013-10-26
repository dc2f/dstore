package com.dstore.storage;

import java.io.File;

import org.mapdb.DB;
import org.mapdb.DBMaker;

public class MapDBProvider {

	static DB createFileDB(String file) {
		return DBMaker.newFileDB(new File(file)).make();
	}
}
