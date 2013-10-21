import ceylon.collection { MutableMap }
"Exception when trying to add a node that already exists"
shared class NodeExistsException(String description) 
		extends Exception(description) {}

"Intersection type of accepted primitve property types"
shared alias PropertyPrimitive => <String|Integer|Float>;

"Intersection type of property primitives and iterables of property primitives"
shared alias Property => <PropertyPrimitive|{PropertyPrimitive*}>;

"A node in the tree"
shared interface Node {
	
	"The name of a node"
	shared formal String name;
	
	"The parent node of the node"
	shared formal Node? parent;
	
	"The children of the node"
	shared formal MutableMap<String, Node> children;
	
	"The properties of the node"
	shared formal MutableMap<String, Property> properties;
	
	shared formal variable String nodeHash;
	shared formal variable String childrenHash;
	shared formal variable String propertiesHash;
}