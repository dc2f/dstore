import ceylon.collection {
	HashMap
}

import com.dstore.node {
	WorkingTreeNode
}
import com.dstore.storage {
	Storage, StoredNode
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
	value workspaceNodes = HashMap<String, [WorkingTreeNode, StoredNode?]>();
	
	"The root node of the working tree"
	shared WorkingTreeNode rootNode {
		return getNodeByStoreId(baseCommit.rootNode);
	}
	
	"Get a node by it's storeId."
	shared WorkingTreeNode getNodeByStoreId(String storeId) {
		
		if(exists pair = workspaceNodes.get(storeId)) {
			return pair[0];
		} else {
			value storedNode = storage.readNode(storeId);
			value node = WorkingTreeNode {
				workingTree = this;
				storeId = storedNode.storedId;
				name = storedNode.name;
				storedChildren = storedNode.children;
			};
			
			workspaceNodes.put(storeId, [node, storedNode]);
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
		value storeId = storage.uniqueId();
		return WorkingTreeNode(this, storeId, name);
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