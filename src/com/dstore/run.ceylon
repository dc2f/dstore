
void run() {
	value a = Node("A");
	value b = a.addChild(Node("B"));
	a.addChild(Node("C"));
	value d = a.addChild(Node("D"));
	b.addChild(Node("E"));
	b.addChild(Node("F"));
	b.addChild(Node("G"));
	b.addChild(Node("H"));
	value i = d.addChild(Node("I"));
	d.addChild(Node("J"));
	value k = d.addChild(Node("K"));
	d.addChild(Node("L"));
	d.addChild(Node("M"));
	d.addChild(Node("N"));
	value o = d.addChild(Node("O"));
	i.addChild(Node("R"));
	i.addChild(Node("S"));
	o.addChild(Node("P"));
	o.addChild(Node("X"));
	k.addChild(Node("Q"));
	
	print(a.string);
}