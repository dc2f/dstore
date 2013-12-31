import com.dstore {
	Property
}

"Only the raw ids and other basic info about the node"
shared class FlatStoredNode(storedId, name, childrenId, propertiesId) {
	
	"The unique id of exactly this node in this version."
	shared String storedId;
	
	"The name of the node."
	shared String name;
	
	"The unique id of exactly this nodes children in this version."
	shared String childrenId;
	
	"The id of the properties of this node.
	 
	 **This doesn't need to be unique.**
	 It can be reused for other nodes with the exact same properties."
	shared String propertiesId;
}

"A stored node as read from the underlying storage including children references and properties"
shared class StoredNode(
			String storedId, String name,
			String childrenId, String propertiesId, 
			children, properties) 
		extends FlatStoredNode(storedId, name, childrenId, propertiesId) {
		
	"The children of the node mapped as child name -> child storeId"
	shared Map<String, String> children;
	
	"The properties of the node mapped as property name -> property value."
	shared Map<String, Property> properties;
}