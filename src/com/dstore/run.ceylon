import com.dstore.storage {
	HashMapStorage
}

void analyze(String msg, WorkingTree wt) {
	print(msg);
	print(wt.rootNode);
}

void run() {
	value dstore = DStore(HashMapStorage());
	value wt1 = dstore.checkout("master");
	assert(exists wt1);
	
	value root = wt1.rootNode;
	value a = root.addChild("A");
	value b = root.addChild("B");
	
	a.addChild("A1");
	a.addChild("A2");
	
	b.addChild("B1");
	b.addChild("B2");
	
	analyze("created some nodes in wt1", wt1);
	
	value wt2 = dstore.checkout("master");
	assert(exists wt2);
	
	analyze("new wt2 must see only original root node", wt2);
	
	print("commit wt1");
	wt1.commit();
	
	analyze("root node id of wt1 must have changed", wt1);
	analyze("wt2 must not see any changes", wt2);
	
	value wt3 = dstore.checkout("master");
	assert(exists wt3);
	
	analyze("even a new wt3 of master must not see any changes", wt3);
}