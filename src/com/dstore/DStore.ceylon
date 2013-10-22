import com.dstore.storage {
	Storage
}


"entry point for the dstore"
class DStore(storage) {
	
	Storage storage;
	
	"Checks out a branch as the working tree.
	 
	 Returns null if the branch doesn't exist."
	shared WorkingTree? checkout(String branchName) {
		if(exists commit = storage.readBranch(branchName)) {
			return WorkingTree(storage, commit, branchName);
		}
		return null;
	}
}