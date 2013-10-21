import com.dstore.hash {
	Sha1
}

"A commit"
shared class Commit(
			rootNode,
			parents,
			message = ""
		) {
	
	shared {Commit*} parents;
	shared String rootNode; 
	shared String message;
	
	shared String commitHash = Sha1()
			.add(parents*.commitHash)
			.add(rootNode)
			.add(message)
			.string;
}