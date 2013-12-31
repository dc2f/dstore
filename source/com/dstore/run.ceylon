import com.dstore.storage {
	HashMapStorage
}

"Prints the msg and the given wt"
void analyze(String msg, WorkingTree wt) {
	print(msg);
	print(wt.rootNode);
}

void simple() {
	value storage = HashMapStorage();
	value dstore = DStore(storage);
	value wt1 = dstore.checkoutBranch("master");
	assert(exists wt1);
	
	value root = wt1.rootNode;
	value a = root.addChild("A");
	value b = root.addChild("B");
	
	value a1 = a.addChild("A1");
	a.addChild("A2");
	
	value c1 = wt1.commit();
	analyze("Commited first changes", wt1);
	
	a1.addChild("A11");
	wt1.commit();
	
	analyze("Commited A11", wt1);
	
	value wt2 = dstore.checkoutCommit(c1.storeId);
	assert(exists wt2);
	
	analyze("checkout out c1", wt2);
}

void run() {
	value storage = HashMapStorage();
	value dstore = DStore(storage);
	value wt1 = dstore.checkoutBranch("master");
	assert(exists wt1);
	
	value root = wt1.rootNode;
	value a = root.addChild("A");
	value b = root.addChild("B");
	a.properties.put("pAx", "Hello World");
	
	a.addChild("A1");
	a.addChild("A2");
	
	value b1 = b.addChild("B1");
	b.addChild("B2");
	
	analyze("created some nodes in wt1", wt1);
	
	value wt2 = dstore.checkoutBranch("master");
	assert(exists wt2);
	
	analyze("new wt2 must see only original root node", wt2);
	
	print("(1) commit wt1");
	value c1 = wt1.commit();
	
	analyze("root node id of wt1 must have changed", wt1);
	
	print("(2) commit wt1 a second time without changing anything");
	value c2 = wt1.commit();
	
	analyze("nothing has to be changed by the second commit", wt1);
	
	analyze("wt2 must not see any changes", wt2);
	
	b1.addChild("B11");
	value c3 = wt1.commit();
	analyze("(3) B1, B, and root node must have been changed after adding B11", wt1);
	
	value wt3 = dstore.checkoutBranch("master");
	assert(exists wt3);
	
	analyze("even a new wt3 of master must not see any changes", wt3);
	
	value wtC1 = dstore.checkoutCommit(c1.storeId);
	value wtC2 = dstore.checkoutCommit(c2.storeId);
	value wtC3 = dstore.checkoutCommit(c3.storeId);
	assert(exists wtC1, exists wtC2, exists wtC3);
	
	print(wtC1.rootNode.storedNode?.childrenId else "no children id");
	value storedNode = wtC1.rootNode.storedNode;
	
	analyze("new wtC1 of commit1 must be the same as before in (1)", wtC1);
	analyze("new wtC2 of commit2 must be the same as before in (2)", wtC2);
	analyze("new wtC2 of commit3 must be the same as before in (3)", wtC3);
}