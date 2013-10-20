
void run() {
	value a = Node("A");
	value b = a.addChild("B");
	a.addChild("C");
	value d = a.addChild("D");
	b.addChild("E");
	b.addChild("F");
	b.addChild("G");
	b.addChild("H");
	value i = d.addChild("I");
	value j = d.addChild("J");
	value k = d.addChild("K");
	d.addChild("L");
	d.addChild("M");
	d.addChild("N");
	value o = d.addChild("O");
	i.addChild("R");
	i.addChild("S");
	o.addChild("P");
	o.addChild("X");
	value q = k.addChild("Q");
	
	print(a.string);
	a.updateHashes();
	print(a.string);
	q.setProperty("PropQ1", "Value Q1");
	j.addChild("JJ");
	a.updateHashes();
	print(a.string);
	
}