"A commit"
shared class Commit(
			storeId,
			rootNode,
			parents,
			message = ""
		) {
	
	"Store id of this commit"
	shared String storeId;
	
	"Parent commits"
	shared {Commit*} parents;
	
	"Store id of the root node in this commit"
	shared String rootNode;
	
	"Commit message" 
	shared String message;
}