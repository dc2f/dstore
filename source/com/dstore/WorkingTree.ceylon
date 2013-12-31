import ceylon.collection {
	HashSet,
	HashMap,
	LinkedList
}

import com.dstore.node {
	WorkingTreeNode
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
	String? branchName;
	
	"Nodes that are propably changed.
	 A node is changed when its children have changed or its properties.
	 
	 It can be that the the node practically isn't dirty because someone 
	 changed a property and than changed it back to the old value."
	shared HashSet<WorkingTreeNode> changedNodes = HashSet<WorkingTreeNode>();
	
	"All nodes loaded by this working tree indexed by store id"
	value loadedNodes = HashMap<String, WorkingTreeNode>();
	
	"Loads a node from the store and returns it as a WorkingTreeNode of this WorkingTree"
	WorkingTreeNode loadNode(String storeId, WorkingTreeNode? parent) {
		value storedNode = storage.readNode(storeId);
		value node = WorkingTreeNode {
			storeId = storedNode.storedId;
			name = storedNode.name;
			parent = parent;
			storedNode = storedNode;
			storedProperties = storedNode.properties;
			storedChildren = storedNode.children;
		};
		// TODO: check if it is somehow possible to set a `late` property in the constructor
		// If not beg on the mailing list to allow this 
		node.workingTree = this;
		loadedNodes.put(storeId, node);
		
		return node;
	}
	
	"The root node of the working tree"
	shared WorkingTreeNode rootNode = loadNode(baseCommit.rootNode, null);
	
	"Get a node by its store id"
	shared Node getNodeByStoreId(String storeId, WorkingTreeNode? parent) {
		if(exists node = loadedNodes[storeId]) {
			return node;
		} else {
			return loadNode(storeId, parent);
		}
	}
	
	"Get a node from a slash separated path"
	shared Node? getPath(String path) {
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
	
	"Creates a new node for the given parent node and name"
	shared Node createNode(WorkingTreeNode parent, String name) {
		value node = WorkingTreeNode(storage.uniqueId(), name, parent);
		node.workingTree = this;
		
		loadedNodes.put(node.storeId, node);
		changedNodes.add(node);
		return node;
	}
	
	"Find all nodes that must be updated in the store"
	Set<WorkingTreeNode> findNodesToUpdate() {
		/*
		 TODO: check all updated nodes against the stored node if it has really changed (and what)
		 This would avoid re-writes when changeing a property and afterwards changing it back
		 Alternatively this could be tracked in the node itself. Don't know what would be more efficient.
		 */ 
		
		value toUpdate = HashSet<WorkingTreeNode>(); 
		
		for(changedNode in changedNodes) {
			value changed = LinkedList<WorkingTreeNode>();
			
			variable Boolean first = true;
			variable WorkingTreeNode node = changedNode;
			
			while(true) {				
				// node has changed and node definitely is attached to root
				if(toUpdate.contains(node)) {
					toUpdate.addAll(changed);
					break;
				}
				
				if(first) {
					first = false;
				} else {
					node.childrenChanged = true;
				}
				
				changed.add(node);
				
				if(exists p = node.parent) {
					node = p;
				} else {
					// if the last node isn't the root node, 
					// the node is detached from the tree and we don't need to write it
					if(node == rootNode) {
						toUpdate.addAll(changed);
					}
					break;
				}
			}
		}
		
		return toUpdate;
	}
	
	"Commits the current working tree with the given message"
	shared Commit commit(String message = "") {
		value nodesToUpdate = findNodesToUpdate();
		
		// give the ones to update a new id before storing, otherwise child ids won't match
		for(WorkingTreeNode node in nodesToUpdate) {
			if(node.stored) {
				node.storeId = storage.uniqueId();
			}
		}
		
		// write all nodes to update
		for(WorkingTreeNode node in nodesToUpdate) {
			String|Map<String, String> children;
			if(node.childrenChanged) {
				children = HashMap<String, String>(
					node.children.mixed.mapItems((String key, Node|String item) {
						switch(item)
						case(is String) {
							return item;
						}
						case(is Node) {
							return item.storeId;
						}
					})
				);
			} else {
				if(exists stored = node.storedNode, exists childrenId = stored.childrenId) {
					children = childrenId;
				} else {
					children = emptyMap;
				}
			}
			
			String|Map<String, Property> properties;
			if (node.propertiesChanged) {
				// if properties changed, we need to save it..
				properties = HashMap<String, Property>(node.properties);
			} else {
				// otherwise just use the old id.
				if (exists stored = node.storedNode, exists propertiesId = stored.propertiesId) {
					properties = propertiesId;
				} else {
					properties = emptyMap;
				}
			}
			
			// node is now clean
			node.childrenChanged = false;
			node.propertiesChanged = false;
			changedNodes.remove(node);
			
			node.storedNode = storage.writeNode { 
				storedId = node.storeId; 
				name = node.name; 
				parentId = node.parent?.storeId;
				children = children;
				properties = properties;
			};
		}
		
		value commit = Commit(storage.uniqueId(), rootNode.storeId, {baseCommit}, message);
		storage.storeCommit(commit);
		
		this.baseCommit = commit;
		return commit;
	}
}