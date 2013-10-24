import ceylon.collection {
	HashMap
}

import com.dstore {
	Commit,
	Property
}
import com.dstore.hash {
	Sha1
}
import java.util {
	UUID { randomUUID }
}

"Thrown when a hash is needed but none is available"
shared class NoHashException(String message) extends Exception(message) {}

"Storage backend to store data"
shared interface Storage {
	
	"Generates a new unique id"
	shared formal String uniqueId();
	
	"Reads a commit with the given id."
	shared formal Commit? readCommit(String id);
	
	"stores the given commit with its id"
	shared formal void storeCommit(Commit commit);
	
	"Get a branch by its name"
	shared formal Commit? readBranch(String name);
	
	"Create a branch for the given commit"
	shared formal void storeBranch(String name, Commit commit);
	
	"Reads a node with the given storage id."
	shared formal StoredNode readNode(String id);
	
	"Writes / updates a node."
	shared formal FlatStoredNode writeNode(
			String storedId, String name, String? parentId, 
			String|Map<String, String> children = emptyMap, 
			String|Map<String, Property> properties = emptyMap);
}


"Simple storage implementation based on hash maps"
shared class HashMapStorage() satisfies Storage {

	"name -> commitId"
	value storedBranches = HashMap<String, String>();
	
	"commitId -> commit"
	value storedCommits = HashMap<String, Commit>();
	
	"storedId -> node"
	value storedNodes = HashMap<String, FlatStoredNode>();
	
	"childrenId -> (name -> storedId)"
	value storedChildren = HashMap<String, Map<String, String>>();
	
	"propertyId -> (name -> value)"
	value storedProperties = HashMap<String, Map<String, Property>>(); 

	shared actual String uniqueId() {
		return randomUUID().string;
	}

	shared actual Commit? readCommit(String id) {
		return storedCommits.get(id);
	}
	
	shared actual void storeCommit(Commit commit) {
		storedCommits.put(commit.storeId, commit);
	}
	
	shared actual Commit? readBranch(String name) {
		if(exists id = storedBranches.get(name)) {
			return storedCommits.get(id);
		}
		return null;
	}
	
	shared actual void storeBranch(String name, Commit commit) {
		storedBranches.put(name, commit.storeId);
	}
	
	shared actual StoredNode readNode(String storeId) {
		value node = storedNodes.get(storeId);
		assert(exists node);
		value children = storedChildren.get(node.childrenId);
		value properties = storedProperties.get(node.propertiesId);
		assert(exists children, exists properties);
		
		return StoredNode(node.storedId, node.name, node.childrenId, node.propertiesId, children, properties);
	}
	
	String storeChildren(Map<String, String> children) {
		value id = uniqueId();
		storedChildren.put(id, children);
		return id;
	}
	
	String storeProperties(Map<String, Property> properties) {
		value hasher = Sha1();
		for(key -> item in properties) {
			hasher.add(key);
			hasher.add(item);
		}
		
		value id = hasher.string;
		storedProperties.put(id, properties);
		return id;
	}
	
	shared actual FlatStoredNode writeNode(
		String storedId, String name, String? parentId, 
		String|Map<String, String> children, 
		String|Map<String, Property> properties) {
		
		String childrenId;
		
		if(is String children) {
			childrenId = children;
		} else {
			assert(is Map<String, String> children);
			childrenId = storeChildren(children);
		}
		
		String propertiesId;
		if(is String properties) {
			propertiesId = properties;
		} else {
			assert(is Map<String, String> properties);
			propertiesId = storeProperties(properties);
		}
		
		value node = FlatStoredNode(storedId, name, childrenId, propertiesId);
		storedNodes.put(storedId, node);
		
		return node;
	}
	
	shared actual String string {
		value b = StringBuilder();
		for(value id -> node in storedNodes) {
			b.append("Node ``node.name`` (``node.storedId``)\n");
			b.append(" + Children (``node.childrenId``)\n");
			value children = storedChildren[node.childrenId];
			assert(exists children);
			for(name -> child in children) {
				b.append("   - ``name`` (``child``)\n");
			}
			b.append(" + Properties (``node.propertiesId``)\n");
			value properties = storedProperties[node.propertiesId];
			assert(exists properties);
			for(name -> property in properties) {
				b.append("   - ``name`` (``property``)\n");
			}
		}
		return b.string;
	}
}