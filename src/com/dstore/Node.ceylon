import ceylon.collection {
	HashMap
}
import com.dstore.hash { Sha1 }

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
	
	HashMap<String, Node> childNodes = HashMap<String, Node>();
	HashMap<String, Property> properties = HashMap<String, Property>();
	
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
		properties.put(name, property);
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
	shared Node addChild(Node node) {
		if(childNodes.defines(node.name)) {
			throw NodeExistsException("Node ``node.name`` already exists");
		}
		node.parent = this;
		childNodes.put(node.name, node);
		return node;
	}
	
	"Remove a child from the node"
	shared void removeChild(String name) {
		childNodes.remove(name);
	}
	
	"Updates the hashes of this node.
	 
	 Note that this never recalculates the hashes of child nodes.
	 The hashes of child nodes must be updated before updating this hash."
	shared void rehash(
			"If the properties hash should be recalculated"
			Boolean recalcPropertiesHash = false,
			"If the children hash should be recalculated"
			Boolean recalcChildrenHash = false) {
		
		value sha1 = Sha1();
		
		if(recalcChildrenHash) {
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
		}
		
		if(recalcPropertiesHash) {
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
		}
		
		sha1.add(name);
		
		if(exists ch = childrenHash) {
			sha1.add(ch);
		}
		if(exists ph = propertiesHash) {
			sha1.add(ph);
		}
	}
	
	"Prints the node recursively as string
	 to the given builder with the given start indentation."
	void print(StringBuilder b, Integer indent) {
		b.append(" ".repeat(indent));
		b.append("+ ``name`` (n: ``nodeHash?.spanTo(5) else "no node hash"`` ");
		b.append("p: ``propertiesHash?.spanTo(5) else "no properties hash"`` ");
		b.append("c: ``childrenHash?.spanTo(5) else "no children hash"``");
		b.append(")\n");
		
		for(name -> prop in properties) {
			b.append(" ".repeat(indent + 1));
			b.append("- ``name``: ");
			if(is PropertyPrimitive prop) {
				b.append(prop.string);
			} else if (is {PropertyPrimitive*} prop) {
				b.append("[");
				b.append(", ".join(prop*.string));
			}
		}
		for(name -> child in childNodes) {
			child.print(b, indent +2);
		}
	}
	
	"Prints the tree from this node down as pretty string"
	shared actual String string {
		value b = StringBuilder();
		print(b, 0);
		return b.string;
	}
}