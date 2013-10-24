import com.dstore {
	WorkingTree,
	Node,
	NodeExistsException
}
import com.dstore.collection {
	LazyTransformingMap
}

"The working tree aware node implementation"
shared class WorkingTreeNode(storeId, name, parent, storedChildren = emptyMap) satisfies Node {
	
	"The working tree this node belongs to"
	shared late WorkingTree workingTree;
	
	"The store id of this node"
	shared actual variable String storeId;
	
	"The name of this node"
	shared actual String name;
	
	"The parent of this node"
	shared actual variable WorkingTreeNode? parent;
	
	"A mapping name -> storeId of the stored children of this node"
	shared Map<String, String> storedChildren;
	
	// Only here as workaround to be able to leak `this`.
	// This code could be so much nicer without this stupid transformer object.
	// TODO: Beg on the ceylon mailing list for some more flexibility for leaking `this`
	object transformer {
		shared late WorkingTreeNode node;
		
		shared Node transform (String key) {
			return node.workingTree.loadNode(key, node);
		}
	}
	transformer.node = this;
	
	shared actual LazyTransformingMap<String, String, Node> children = LazyTransformingMap<String, String, Node> {
		transform = transformer.transform;
		initialItems = storedChildren;
	};
			
	"Add a new child"
	shared actual Node addChild(String name) {
		if(children.defines(name)) {
			throw NodeExistsException("The node ``name`` already exists as a child");
		}
		
		Node child = workingTree.createNode(this, name);
		children.put(name, child);
		
		return child;
	}
	
	//shared Map<String, Property> storedProperties;
	
	//shared actual MutableMap<String, Property> properties;
	
	string => NodePrinter(this).string;
}