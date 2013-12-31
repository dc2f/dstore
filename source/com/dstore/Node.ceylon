import ceylon.collection { MutableMap }

"Exception when trying to add a node that already exists"
shared class NodeExistsException(String description) 
		extends Exception(description) {}

"Intersection type of property primitives and iterables of property primitives"
shared alias Property => PropertyPrimitive|{PropertyPrimitive*};

"Intersection type of accepted primitve property types"
shared alias PropertyPrimitive => String|Integer|Float;

"A node in the tree"
shared interface Node {
	
	"The name of a node"
	shared formal String name;
	
	//"The parent node of the node"
	shared formal Node? parent;
	
	"The children of the node"
	shared formal Map<String, Node> children;
	
	"Adds a child with the given name to the node"
	shared formal Node addChild(String name);
	
	"The properties of the node"
	shared formal MutableMap<String, Property> properties;
	
	"The globally unique id of the node.
	 Every commited change in a node will lead to a new storage id."
	shared formal variable String storeId;
}