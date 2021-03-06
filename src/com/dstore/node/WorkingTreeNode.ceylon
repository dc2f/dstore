import com.dstore {
	WorkingTree,
	Node,
	NodeExistsException, Property
}
import com.dstore.collection {
	LazyTransformingMap, NotifyingMutableMap
}
import com.dstore.storage {
	FlatStoredNode
}
import ceylon.collection { MutableMap, HashMap }

"The working tree aware node implementation"
shared class WorkingTreeNode(
	storeId,
	name,
	parent,
	storedChildren = emptyMap,
	storedProperties = emptyMap,
	storedNode = null) satisfies Node {
	
	// FIXME: late self reference ;-) nicest workaround there is..
	shared late WorkingTreeNode self;
	self = this;

	"If the children of this node have changed"
	shared variable Boolean childrenChanged = false;
	
	"If any properties have changed."
	shared variable Boolean propertiesChanged = false;

	"The stored node from which this node was loaded"
	shared variable FlatStoredNode? storedNode;

	"If the node is new or has been stored already"
	shared Boolean new {
		if(exists stored = storedNode) { 
			return false;
		} else {
			return true;
		}
	}

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
	
	shared Map<String, Property> storedProperties;
	
	shared actual MutableMap<String, Property> properties = NotifyingMutableMap<String, Property> {
		wrapped = HashMap<String, Property>(storedProperties);
		void afterChange() {
			self.propertiesChanged = true;
			self.workingTree.changedNodes.add(self);
		}
		
	};
	
	shared actual LazyTransformingMap<String, String, Node> children = LazyTransformingMap<String, String, Node> {
		Node transform(String key) {
			return self.workingTree.getNodeByStoreId(key, self);
		}
		initialItems = storedChildren;
	};
			
	"Add a new child"
	shared actual Node addChild(String name) {
		if(children.defines(name)) {
			throw NodeExistsException("The node ``name`` already exists as a child");
		}
		
		Node child = workingTree.createNode(this, name);
		children.put(name, child);
		
		childrenChanged = true;
		workingTree.changedNodes.add(this);
		
		return child;
	}
	
	//shared Map<String, Property> storedProperties;
	
	//shared actual MutableMap<String, Property> properties;
	
	string => NodePrinter(this).string;

}
