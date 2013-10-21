import com.dstore.storage { Storage }

"A working area where it is possible to get and modify the nodes."
shared class WorkingTree(storage, commit, branchName) {
	
	"The storage where to look up the data."
	Storage storage;
	
	"The commit this working tree is based on."
	variable Commit commit;
	
	"The name of the branch where this working tree was based on.
	 This is just stored for pushing without specifiying the branch name again."
	String branchName;
	
	"The root node of the working tree"
	shared Node rootNode = storage.readNode(commit.rootNode);
	
	"Get a node from a slash separated path"
	shared Node? getNode(String path) {
		variable Node? node = rootNode;
		for (name in path.split((Character char) => char == "/", true)) {
			node = node?.getChild(name);
			if(node is Null) {
				break;
			}
		}
		
		return node;
	}
}