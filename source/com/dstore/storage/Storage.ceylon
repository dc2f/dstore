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
		
		Map<String, String> children;
		
		if(exists childrenId = node.childrenId) {
			value c = storedChildren.get(childrenId);
			assert(exists c);
			children = c;
		} else {
			children = emptyMap;
		}
		
		Map<String, Property> properties;
		if(exists propertiesId = node.propertiesId) {
			value p = storedProperties.get(propertiesId);
			assert(exists p);
			properties = p;
		} else {
			properties = emptyMap;
		}
		
		return StoredNode(node.storedId, node.name, node.childrenId, node.propertiesId, children, properties);
	}
	
	String storeChildren(Map<String, String> children) {
		value id = uniqueId();
		storedChildren.put(id, children);
		return id;
	}
	
	String storeProperties(Map<String, Property> properties) {
		value hasher = Sha1();
		// TODO improve hashing to avoid conflicts (separator for key/value?)
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
		
		switch (children)
		case (is String) {
			childrenId = children;
		} case (is Map<String, String>) {
			childrenId = storeChildren(children);
		}
		
		String propertiesId;
		switch (properties)
		case (is String) {
			propertiesId = properties;
		} case (is Map<String, Property>) {
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
			if(exists childrenId = node.childrenId) {
				b.append(" + Children (``childrenId``)\n");
				value children = storedChildren[childrenId];
				assert(exists children);
				for(name -> child in children) {
					b.append("   - ``name`` (``child``)\n");
				}
			}
			if(exists propertiesId = node.propertiesId) {
				b.append(" + Properties (``propertiesId``)\n");
				value properties = storedProperties[propertiesId];
				assert(exists properties);
				for(name -> property in properties) {
					b.append("   - ``name`` (``property``)\n");
				}
			}
		}
		return b.string;
	}
}