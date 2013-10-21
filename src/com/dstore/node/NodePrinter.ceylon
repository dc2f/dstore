import com.dstore {
	PropertyPrimitive,
	Node
}
"Prints nodes in an readable format"
class NodePrinter(NodeImpl node) {
	
	"Prints the node recursively as string
	 to the given builder with the given start indentation."
	void printTree(Node node, StringBuilder b, Integer indent) {
		b.append(" ".repeat(indent));
		b.append(node.children.empty then "-" else "+");
		b.append(" ``node.name``");
		/*
		b.append(" (n: ``node.nodeHash?.spanTo(5) else "no node hash"`` ");
		b.append("c: ``node.childrenHash?.spanTo(5) else "no children hash"`` ");
		b.append("p: ``node.propertiesHash?.spanTo(5) else "no properties hash"``");
		b.append(")\n");
		*/
		
		for(name -> prop in node.properties) {
			b.append(" ".repeat(indent + 2));
			b.append("* ``node.name``: ");
			if(is PropertyPrimitive prop) {
				b.append(prop.string);
			} else if (is {PropertyPrimitive*} prop) {
				b.append("[");
				b.append(", ".join(prop*.string));
			}
			b.append("\n");
		}
		for(child in node.children.values) {
			printTree(child, b, indent +2);
		}
	}
	
	shared actual String string {
		value b = StringBuilder();
		printTree(node, b, 0);
		return b.string;
	}
}