import ceylon.collection {
	HashMap
}

import com.dstore {
	Commit, WorkingTree
}
import com.dstore.node {
	NodeImpl
}

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
	shared formal NodeImpl readNode(String id, WorkingTree workingTree);
	
	"Writes a node with the given id."
	throws(`class NoHashException`, "When the node has no nodeHash.")
	shared formal void writeNode(NodeImpl node);
	
	"Get a branch by its name"
	shared formal Commit? readBranch(String name);
	
	"Create a branch for the given commit"
	shared formal void writeBranch(String name, Commit commit);
}

"Simple storage implementation based on hash maps"
shared class HashMapStorage() satisfies Storage {

	value commits = HashMap<String, Commit>();
	value nodes = HashMap<String, NodeImpl>();
	
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
	
	/*
	 FIXME: reference to working tree is pure bullshit here.
	 Store should return and get some more generic format
	*/
	shared actual NodeImpl readNode(String id, WorkingTree workingTree) {
		// FIXME after node refactoring
		value node = nodes.get(id);
		assert(exists node);
		
		return NodeImpl(node.name, node.parentId, workingTree, node.nodeHash, node.childrenHash, node.propertiesHash);
	}
	
	shared actual void writeNode(NodeImpl node) {
		nodes.put(node.nodeHash, node);
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