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
	HashMap<String, Commit> commits = HashMap<String, Commit>();
	
	BTreeMap<String, String> branches = db.getTreeMap<String, String>("branches");
	BTreeMap<String, FlatStoredNode> nodes = db.getTreeMap<String, FlatStoredNode>("nodes");
	
	// nodeId -> JSON object with child name -> children 
	BTreeMap<String, String> children = db.getTreeMap<String, String>("children");
	
	//NavigableSet<Tuple2<String,Serializable>> properties = db.getTreeSet<Tuple2<String, Serializable>>("properties");

	shared actual String uniqueId() => randomUUID().string;

	shared actual Commit? readBranch(String name) {
		if(exists commitId = branches.get(name)) {
			return commits.get(commitId);
		}
		
		return  null;
	}
	
	shared actual void storeBranch(String name, Commit commit) {
		branches.put(name, commit.storeId);
	}
	
	shared actual Commit? readCommit(String commitId) {
		return commits.get(commitId);
	}
	
	shared actual void storeCommit(Commit commit) {
		commits.put(commit.storeId, commit);
	}
	
	shared actual StoredNode readNode(String id) {
		value flat = nodes.get(id);
		value nodeChildren = findSecondaryKeys(children, flat.childrenId);
		value nodeChildrenMap = HashMap<String, String>();
		
		value childIt = nodeChildren.iterator();
		while(childIt.hasNext()) {
			value pair = childIt.next();
			nodeChildrenMap.put(pair.a, pair.b);
		}
		
		return StoredNode { 
			storedId = flat.storedId;
			name = flat.name;
			childrenId = flat.childrenId; 
			propertiesId = flat.propertiesId; 
			children = nodeChildrenMap; 
			properties = emptyMap;
		};
	}
	
	shared actual FlatStoredNode writeNode(
			String storedId, String name, String? parentId, 
			String|Map<String,String> children, 
			String|Map<String, Property> properties) {
		
		
	}
	
	shared void close() {
		db.close();
	}
}