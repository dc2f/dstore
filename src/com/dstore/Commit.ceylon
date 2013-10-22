"A commit"
shared class Commit(
			rootNode,
			parents,
			commitId,
			message = ""
		) {
	
	shared {Commit*} parents;
	shared String rootNode; 
	shared String message;
	
	shared String commitId;
}