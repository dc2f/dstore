import ceylon.collection {
	HashMap
}

import com.dstore.node {
	NodeImpl
}
import com.dstore.storage {
	Storage
}

"A working area where it is possible to get and modify the nodes."
shared class WorkingTree(storage, baseCommit, branchName) {
	
	"The storage where to look up the data."
	Storage storage;
	
	"The commit this working tree is based on."
	variable Commit baseCommit;
	
	"The name of the branch where this working tree was based on.
	 This is just stored for pushing without specifiying the branch name again."
	String branchName;
	
	"The nodes loaded in this workspace by their id"
	value loadedNodes = HashMap<String, NodeImpl>();
	
	"The root node of the working tree"
	shared NodeImpl rootNode {
		return getNodeById(baseCommit.rootNode);
	}
	
	"Get a node by it's id."
	shared NodeImpl getNodeById(String nodeId) {
		if(exists node = loadedNodes.get(nodeId)) {
			return node;
		} else {
			value node = storage.readNode(nodeId, this);
			loadedNodes.put(nodeId, node);
			return node;
		}
	}
	
	"Get a node from a slash separated path"
	shared Node? getNode(String path) {
		variable Node node = rootNode;
		for (name in path.split((Character char) => char == "/", true)) {
			value child = node.children[name];
			if(exists child) {
				node = child;
			} else {
				break;
			}
		}
		
		return node;
	}
	
	"creates a node with the given name"
	shared Node createNode(String name) {
		// TODO: fixme
		return NodeImpl(name, null, this, "hash", "hash", "hash");
	}
	
	/*
	"Recusivley commits the given node"
	void commitNode(NodeImpl node) {
		if(!updatedProperties && !removedChildren && updatedChildren.empty) {
			return;
		}
		
		value sha1 = Sha1();
		
		if(!updatedChildren.empty) {
			// rehash all dirty children
			for(childName in updatedChildren) {
				assert(exists child = childMap[childName]);
				child.updateHashes();
			}
		}
		
		if(removedChildren || !updatedChildren.empty) {
			// update our own children hash
			if(!childMap.empty) {
				for(name -> node in childMap) {
					String? childHash = node.nodeHash;
					assert(exists childHash);
					sha1.add(childHash);
				}
				childrenHash = sha1.string;
				sha1.reset();
			} else {
				childrenHash = null;
			}
			
			// no more dirty or removed children
			removedChildren = false;
			updatedChildren.clear();
			
			print("updated children hash of ``name``");			
		}
		
		if(updatedProperties) {
			if(!propertiesMap.empty) {
				for(name -> property in propertiesMap) {
					sha1.add(name);
					sha1.add(property);
				}
				propertiesHash = sha1.string;
				sha1.reset();
			} else {
				propertiesHash = null;
			}
			
			// no more updated properties
			updatedProperties = false;
			
			print("updated properties hash of ``name``");
		}
		
		sha1.add(name);
		
		if(exists ch = childrenHash) {
			sha1.add(ch);
		}
		if(exists ph = propertiesHash) {
			sha1.add(ph);
		}
		nodeHash = sha1.string;
		
		print("updated node hash of ``name``");
	}
	
	"Commits the current working tree"
	shared Commit commit() {
		return Commit("test", {});
	}
	 */
}