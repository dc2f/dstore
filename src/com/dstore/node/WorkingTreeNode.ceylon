import ceylon.collection {
	MutableMap, HashMap
}

import com.dstore {
	WorkingTree,
	Node,
	Property
}

"The working tree aware node implementation"
shared class WorkingTreeNode(workingTree, storeId, name, storedChildren = emptyMap) satisfies Node {
	
	WorkingTree workingTree;
	
	shared actual variable String storeId;
	
	shared actual String name;
	
	//shared actual variable WorkingTreeNode? parent;
	
	shared Map<String, String> storedChildren;
	
	shared actual MutableMap<String, Node> children = HashMap<String, Node>();
	
	
	//shared Map<String, Property> storedProperties;
	
	//shared actual MutableMap<String, Property> properties;
}