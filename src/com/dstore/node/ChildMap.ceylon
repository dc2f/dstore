import ceylon.collection {
	MutableMap, HashMap
}
import com.dstore { WorkingTree, Node }

shared class ChildMap(workingTree, initialChildren) 
		satisfies MutableMap<String, Node>{

	"The initial children in the map"
	Map<String, String> initialChildren;
	
	"The working tree used to load the children"
	WorkingTree workingTree;
	
	"The node this map belongs to"
	shared late NodeImpl node;
	
	"The current children in the map keyed by thier name"
	HashMap<String, String> children = HashMap(initialChildren);
	
	
	
	shared actual Node? get(Object key) => workingTree.getNodeById(key.string);
	
	shared actual Node? put(String name, Node child) {
		assert(is NodeImpl child);
		variable Node? oldNode = null;
		
		if(exists oldId = children.get(name)) {
			oldNode = workingTree.getNodeById(oldId);
			remove(name);
		}
		
		child.parentId = node.nodeHash;
		children.put(name, child.nodeHash);
		child.dirtParents();
		
		return oldNode;
	}
	
	shared actual void putAll({<String->Node>*} entries) {
		throw Exception("Not implemented");
	}
	
	shared actual void clear() {
		throw Exception("Not implemented");
	}
	
	shared actual Node? remove(String key) {
		throw Exception("Not implemented");
	}
	
	shared actual Iterator<String->Node> iterator() {
		throw Exception("Not implemented");
	}
	
	shared actual ChildMap clone {
		value clone = ChildMap(workingTree, children);
		clone.node = this.node;
		return clone;
	}
	
	shared actual Boolean equals(Object that) {
		if(is ChildMap that) {
			return that.children.equals(this.children);
		}
		return false;
	}
	
	shared actual Integer hash => this.children.hash;
}