import com.dstore {
	WorkingTree,
	Node, NodeExistsException
}
import ceylon.collection { HashMap }

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
	
	"The loaded children of this node"
	shared HashMap<String, Node> loadedChildren = HashMap<String, Node>();
	
	shared class ChildMap() satisfies Map<String, Node> {
		shared late WorkingTreeNode parentNode;
		
		shared actual Boolean equals(Object that) => false; // FIXME: Implement
		
		shared actual Integer hash => 1; // FIXME: Implement
		
		shared actual Map<String,Node> clone = emptyMap;
		
		shared actual Iterator<String->Node> iterator() {
			value keys = loadedChildren.keys.union(storedChildren.keys);
			value keyIterator = keys.iterator();
			
			object iterator satisfies Iterator<String->Node> {
				shared actual <String->Node>|Finished next() {
					if(!is Finished name = keyIterator.next()) {
						value item = get(name);
						assert(exists item);
						
						return name -> item; 
					}
					return finished;
				}
			}
			
			return iterator;
		}
		
		shared actual Node? get(Object name) {
			if(is String name) {
				if(exists node = loadedChildren.get(name)) {
					return node;
				}
				if(exists childId = storedChildren[name]) {
					value child = parentNode.workingTree.loadNode(childId, parentNode);
					loadedChildren.put(name, child);
					return child;
				}
			}
			
			return null;
		}
	}
	
	shared actual ChildMap children = ChildMap();
	children.parentNode = this;
			
	"Add a new child"
	shared actual Node addChild(String name) {
		if(children.defines(name)) {
			throw NodeExistsException("The node ``name`` already exists as a child");
		}
		
		Node child = workingTree.createNode(this, name);
		loadedChildren.put(name, child);
		
		return child;
	}
	
	//shared Map<String, Property> storedProperties;
	
	//shared actual MutableMap<String, Property> properties;
	
	string => NodePrinter(this).string;
}