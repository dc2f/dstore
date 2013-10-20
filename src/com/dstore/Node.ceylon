import ceylon.collection {
	HashMap,
	HashSet
}

import com.dstore.hash {
	Sha1
}

"Exception when trying to add a node that already exists"
shared class NodeExistsException(String description) 
		extends Exception(description) {}

"Intersection type of accepted primitve property types"
shared alias PropertyPrimitive => <String|Integer|Float>;

"Intersection type of property primitives and iterables of property primitives"
shared alias Property => <PropertyPrimitive|{PropertyPrimitive*}>;

"A node in the tree.
 
 Every node has a name. The root node has the name of the empty String (\"\")."
shared class Node(name) {
	"The name of a node"
	shared String name;
	
	"Every node except the root node has a parent"
	shared variable Node? parent = null;
	
	"child nodes indexed by name"
	value childNodes = HashMap<String, Node>();
	"properties indexed by name"
	value properties = HashMap<String, Property>();
	
	"If the node's property hash is dirty"
	variable Boolean updatedProperties = true;
	"The names of the children which were updated. 
	 They either have updated properties or have updated children themself."
	value updatedChildren = HashSet<String>();
	"If children have been removed from this node."
	variable Boolean removedChildren = false;
	
	shared variable String? nodeHash = null;
	shared variable String? childrenHash = null;
	shared variable String? propertiesHash = null;
	
	"The children of the node"
	shared {Node*} children = {
		for(c in childNodes) c.item
	};
	
	"Get a property by its name"
	shared Property? getProperty(String name) {
		return properties[name];
	}
	
	"Sets a property of the node
	 If the property already exists, it is overridden"
	shared void setProperty(String name, Property property) {
		value old = properties.get(name);
		
		if(exists old, property == old) {
			// no change
		} else {
			properties.put(name, property);
			this.updatedProperties = true;
			dirtParents();
		}
	}
	
	"Check if the node has a property with the given name"
	shared Boolean hasProperty(String name) {
		return properties.defines(name);
	}
	
	"Get a child node"
	shared Node? getChild(String name) {
		return childNodes[name];
	}
	
	"Check if the node has the given child"
	shared Boolean hasChild(String name) {
		 return childNodes.defines(name);
	}
	
	"Add a child to the node"
	throws(`class NodeExistsException`, "If a node with the same name already exists.")
	shared Node addChild(String name) {
		if(childNodes.defines(name)) {
			throw NodeExistsException("Node ``name`` already exists");
		}
		
		value node = Node(name);
		childNodes.put(node.name, node);
		node.parent = this;
		node.updatedProperties = true;
		node.dirtParents();
		
		return node;
	}
	
	"Remove a child from the node"
	shared void removeChild(String name) {
		if(hasChild(name)) {
			childNodes.remove(name);
			removedChildren = true;
		}
	}
	
	"Updates the updated children property of all parents."
	void dirtParents() {		
		variable Node lastNode = this;
		variable Node? nextNode = this.parent;
		
		while(exists node = nextNode) {
			node.updatedChildren.add(lastNode.name);
			
			lastNode = node;
			nextNode = node.parent;
		}
	}
	
	"Updates the hashes of this and all dirty child nodes."
	shared void updateHashes() {
		if(!updatedProperties && !removedChildren && updatedChildren.empty) {
			return;
		}
		
		value sha1 = Sha1();
		
		if(!updatedChildren.empty) {
			// rehash all dirty children
			for(childName in updatedChildren) {
				assert(exists child = childNodes[childName]);
				child.updateHashes();
			}
		}
		
		if(removedChildren || !updatedChildren.empty) {
			// update our own children hash
			if(!childNodes.empty) {
				for(name -> node in childNodes) {
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
			if(!properties.empty) {
				for(name -> property in properties) {
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
	
	"Prints the node recursively as string
	 to the given builder with the given start indentation."
	void printTree(StringBuilder b, Integer indent) {
		b.append(" ".repeat(indent));
		b.append(this.childNodes.empty then "-" else "+");
		b.append(" ``name`` (n: ``nodeHash?.spanTo(5) else "no node hash"`` ");
		b.append("c: ``childrenHash?.spanTo(5) else "no children hash"`` ");
		b.append("p: ``propertiesHash?.spanTo(5) else "no properties hash"``");
		b.append(")\n");
		
		for(name -> prop in properties) {
			b.append(" ".repeat(indent + 2));
			b.append("* ``name``: ");
			if(is PropertyPrimitive prop) {
				b.append(prop.string);
			} else if (is {PropertyPrimitive*} prop) {
				b.append("[");
				b.append(", ".join(prop*.string));
			}
			b.append("\n");
		}
		for(name -> child in childNodes) {
			child.printTree(b, indent +2);
		}
	}
	
	"Prints the tree from this node down as pretty string."
	shared actual String string {
		value b = StringBuilder();
		printTree(b, 0);
		return b.string;
	}
}