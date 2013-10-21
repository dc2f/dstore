import ceylon.collection {
	HashMap,
	HashSet
}

import com.dstore {
	Property,
	Node,
	WorkingTree
}

"A node in the tree.
 
 Every node has a name. The root node has the name of the empty String (\"\")."
shared class NodeImpl(
			name, parentId, workingTree,
			nodeHash, childrenHash, propertiesHash,
			storedProps = HashMap<String, Property>(),
			storedChildren = HashMap<String, String>()
		) satisfies Node {
	
	HashMap<String, Property> storedProps;
	HashMap<String, String> storedChildren;
	shared variable String? parentId;
	WorkingTree workingTree;
	
	"The name of a node"
	shared actual String name;
	
	"Every node except the root node has a parent"
	shared actual NodeImpl? parent {
		if(exists id = parentId) {
			return workingTree.getNodeById(id);
		} else {
			return null;
		}
	}
	
	"The children of the node"
	shared actual ChildMap children = ChildMap(workingTree, storedChildren);
	children.node = this;
	
	"The properties of the node"
	shared actual PropertyMap properties = PropertyMap(storedProps);
	properties.node = this;
	
	
	"If the node's property hash is dirty"
	variable Boolean updatedProperties = false;
	
	"The names of the children which were updated. 
	 They either have updated properties or have updated children themself."
	value updatedChildren = HashSet<String>();
	
	"If children have been removed from this node."
	shared variable Boolean removedChildren = false;
	
	shared actual variable String nodeHash;
	shared actual variable String childrenHash;
	shared actual variable String propertiesHash;
	
	/*
	"Get a property by its name"
	shared Property? getProperty(String name) {
		return propertiesMap[name];
	}
	
	"Sets a property of the node
	 If the property already exists, it is overridden"
	shared actual void setProperty(String name, Property property) {
		value old = propertiesMap.get(name);
		
		if(exists old, property == old) {
			// no change
		} else {
			propertiesMap.put(name, property);
			this.updatedProperties = true;
			dirtParents();
		}
	}
	
	"Add a child to the node"
	throws(`class NodeExistsException`, "If a node with the same name already exists.")
	shared actual NodeImpl addChild(String name) {
		if(childMap.defines(name)) {
			throw NodeExistsException("Node ``name`` already exists");
		}
		
		value node = NodeImpl(name);
		childMap.put(node.name, node);
		node.parent = this;
		node.updatedProperties = true;
		node.dirtParents();
		
		return node;
	}
	
	"Remove a child from the node"
	shared actual NodeImpl? removeChild(String name) {
		if(hasChild(name)) {
			removedChildren = true;
			return childMap.remove(name);
		}
		return null;
	}
	*/
	
	"Marks properties as dirty"
	shared void dirtProperties() {
		this.updatedProperties = true;
		dirtParents();
	}
	
	"Updates the updated children property of all parents."
	shared void dirtParents() {		
		variable NodeImpl lastNode = this;
		variable NodeImpl? nextNode = this.parent;
		
		while(exists node = nextNode) {
			node.updatedChildren.add(lastNode.name);
			
			lastNode = node;
			nextNode = node.parent;
		}
	}
	
	"Prints the tree from this node down as pretty string."
	shared actual String string {
		return NodePrinter(this).string;
	}
}