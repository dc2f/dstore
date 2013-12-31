import ceylon.file {
	Path
}

import com.dstore {
	Commit,
	Property
}
import com.dstore.storage {
	MapDBProvider {
		createFileDB
	}
}

import org.mapdb {
	DB,
	BTreeMap,
	Fun { Tuple2 },
	Bind { findSecondaryKeys }
}
import java.util { NavigableSet, UUID { randomUUID }}
import java.io { Serializable }
import ceylon.collection { HashMap }

shared class MapDBStorage(Path filePath) satisfies Storage {

	DB db = createFileDB(filePath.absolute.string);
	
	// commit id -> JSON serialized commits
	HashMap<String, Commit> storedCommits = HashMap<String, Commit>();
	
	// brnach name -> commitId
	BTreeMap<String, String> storedBranches = db.getTreeMap<String, String>("branches");
	
	// nodeId -> JSON object with flat stored nodes as json
	BTreeMap<String, String> storedNodes = db.getTreeMap<String, String>("nodes");
	
	// nodeId -> JSON object with child name -> child nodeId 
	BTreeMap<String, String> storedChildren = db.getTreeMap<String, String>("children");
	
	// nodeId -> JSON object with property name -> property value
	BTreeMap<String, String> storedProperties = db.getTreeMap<String, String>("properties");

	shared actual String uniqueId() => randomUUID().string;

	shared actual Commit? readBranch(String name) {
		if(exists commitId = storedBranches.get(name)) {
			return storedCommits.get(commitId);
		}
		
		return  null;
	}
	
	shared actual void storeBranch(String name, Commit commit) {
		storedBranches.put(name, commit.storeId);
	}
	
	shared actual Commit? readCommit(String commitId) {
		return storedCommits.get(commitId);
	}
	
	shared actual void storeCommit(Commit commit) {
		storedCommits.put(commit.storeId, commit);
	}
	
	shared actual StoredNode readNode(String id) {
		return StoredNode("11", "test", null, null, emptyMap, emptyMap);
	}
	
	shared actual FlatStoredNode writeNode(
			String storedId, String name, String? parentId, 
			String|Map<String,String> children, 
			String|Map<String, Property> properties) {
		
		return FlatStoredNode(storedId, name, null, null);
	}
	
	shared void close() {
		db.close();
	}
}