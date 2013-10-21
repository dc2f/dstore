import com.dstore {
	Commit,
	Node
}
import ceylon.collection { HashMap }

"Thrown when a hash is needed but none is available"
shared class NoHashException(String message) extends Exception(message) {}

"Storage backend to store data"
shared interface Storage {
	
	"Reads a commit with the given id."
	shared formal Commit readCommit(String id);
	
	"stores the given commit with its id"
	shared formal void storeCommit(Commit commit);
	
	"Reads a node with the given id.
	 
	 This must always return a new node instance, since nodes are mutable."
	shared formal Node readNode(String id);
	
	"Writes a node with the given id."
	throws(`class NoHashException`, "When the node has no nodeHash.")
	shared formal void writeNode(Node node);
	
	"Get a branch by its name"
	shared formal Commit? readBranch(String name);
	
	"Create a branch for the given commit"
	shared formal void writeBranch(String name, Commit commit);
}

"Simple storage implementation based on hash maps"
shared class HashMapStorage() satisfies Storage {

	value commits = HashMap<String, Commit>();
	value nodes = HashMap<String, Node>();
	
	// branches stored as name to commit id mapping
	value branches = HashMap<String, String>();

	shared actual Commit readCommit(String id) {
		value commit = commits.get(id);
		assert(exists commit);
		return commit;
	}
	
	shared actual void storeCommit(Commit commit) {
		commits.put(commit.commitHash, commit);
	}
	
	shared actual Node readNode(String id) {
		// Fixme after node refactoring
		value node = nodes.get(id);
		assert(exists node);
		return node;
	}
	
	shared actual void writeNode(Node node) {
		if(exists id = node.nodeHash) {
			nodes.put(id, node);
		} else {
			throw NoHashException("given node has no hash");
		}
	}

	shared actual Commit? readBranch(String name) {
		if(exists id = branches.get(name)) {
			return commits.get(id);
		}
		return null;
	}
	
	shared actual void writeBranch(String name, Commit commit) {
		branches.put(name, commit.commitHash);
	}
}