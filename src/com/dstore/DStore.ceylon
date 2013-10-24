import com.dstore.storage {
	Storage
}

"id of the root commit"
String rootCommitId = "rootCommitId";

"entry point for the dstore"
class DStore(storage) {
	
	Storage storage;
	
	"Create the root node if it dosn't exist.
	 
	 The root node is commited in the very first commit - The root commit.
	 The root commit has a special id named \"rootCommitId\".
	 When creating the root commit it is also initialized to the master branch."
	void initializeRootCommit() {
		value existingRootCommit = storage.readCommit(rootCommitId);
		
		if(is Null existingRootCommit) {
			value rootNode = storage.writeNode { storedId = storage.uniqueId(); name = ""; parentId = null; };
			value rootCommit = Commit { storeId = rootCommitId; rootNode = rootNode.storedId; parents = empty; };
			storage.storeCommit(rootCommit);
			storage.storeBranch("master", rootCommit);
		}
	}
	
	initializeRootCommit();
	
	"Checks out a branch as a new working tree."
	shared WorkingTree? checkoutBranch(String branchName) {
		if(exists commit = storage.readBranch(branchName)) {
			return WorkingTree(storage, commit, branchName);
		}
		return null;
	}
	
	"Check out a commit as a new working tree."
	shared WorkingTree? checkoutCommit(String commitId) {
		if(exists commit = storage.readCommit(commitId)) {
			return WorkingTree(storage, commit, null);
		}
		return null;
	}
}