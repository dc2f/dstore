import com.dstore.node {
	WorkingTreeNode
}
import com.dstore.storage {
	Storage, StoredNode
}
import ceylon.collection { HashSet, HashMap, LinkedList }

"A working area where it is possible to get and modify the nodes."
shared class WorkingTree(storage, baseCommit, branchName) {
	
	"The storage where to look up the data."
	Storage storage;
	
	"The commit this working tree is based on."
	variable Commit baseCommit;
	
	"The name of the branch where this working tree was based on.
	 This is just stored for pushing without specifiying the branch name again."
	String branchName;
	
	"Nodes that are propably changed.
	 A node is changed when its children have changed or its properties.
	 
	 It can be that the the node practically isn't dirty because someone 
	 changed a property and than changed it back to the old value."
	shared HashSet<WorkingTreeNode> changedNodes = HashSet<WorkingTreeNode>();
	
	"All nodes loaded by this working tree indexed by store id"
	value loadedNodes = HashMap<String, [WorkingTreeNode, StoredNode]>();
	
	"Loads a node from the store and returns it as a WorkingTreeNode of this WorkingTree"
	WorkingTreeNode loadNode(String storeId, WorkingTreeNode? parent) {
		value storedNode = storage.readNode(storeId);
		value node = WorkingTreeNode {
			storeId = storedNode.storedId;
			name = storedNode.name;
			parent = parent;
			storedChildren = storedNode.children;
		};
		// TODO: check if it is somehow possible to set a `late` property in the constructor
		// If not beg on the mailing list to allow this 
		node.workingTree = this;
		loadedNodes.put(storeId, [node, storedNode]);
		
		return node;
	}
	
	"The root node of the working tree"
	shared WorkingTreeNode rootNode = loadNode(baseCommit.rootNode, null);
	
	"Get a node by its store id"
	shared Node getNodeByStoreId(String storeId, WorkingTreeNode? parent) {
		if(exists pair = loadedNodes[storeId]) {
			return pair[0];
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
		return node;
	}
	
	"Commits the current working tree with the given message"
	shared Commit commit(String message = "") {
		// TODO: check all updated nodes against the stored node if it has really changed (and what)
		// This would avoid re-writes when changeing a property and afterwards changing it back
		
		// mark all parents of changed nodes also as changed
		value toUpdate = HashSet<WorkingTreeNode>(); 
		
		for(changedNode in changedNodes) {
			value changed = LinkedList<WorkingTreeNode>();
			
			variable Boolean first = true;
			variable WorkingTreeNode node = changedNode;
			while(true) {
				// node has changed and node definitely is attached to root
				if(toUpdate.contains(node)) {
					break;
				}
				
				if(first) {
					first = false;
				} else {
					node.childrenChanged = true;
				}
				
				changed.add(node);
				
				if(exists parent = node.parent) {
					node = parent;
				} else {
					break;
				}
			}
			
			// if the last parent isn't the root node, 
			// the node is detached from the tree and we don't need to write it
			if(node == rootNode) {
				toUpdate.addAll(changed);
			}
		}
		
		// write all nodes to update
		for(WorkingTreeNode node in toUpdate) {
			node.storeId = storage.uniqueId();
			
			String|Map<String, String> children;
			if(node.childrenChanged) {
				children = node.children.mixed.mapItems((String key, Node|String item) {
					switch(item)
					case(is String) {
						return item;
					}
					case(is Node) {
						return item.storeId;
					}
				});
			} else {
				value pair = loadedNodes.get(node.storeId);
				assert(exists pair);
				children = pair[1].childrenId;
			}
			
			// node is now clean
			node.childrenChanged = false;
			changedNodes.remove(node);
			
			storage.writeNode { 
				storedId = node.storeId; 
				name = node.name; 
				parentId = node.parent?.storeId;
				children = children;
			};
		}
		
		value commit = Commit(storage.uniqueId(), rootNode.storeId, {baseCommit}, message);
		storage.storeCommit(commit);
		return commit;
	}
}