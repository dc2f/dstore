import com.dstore {
	Node,
	PropertyPrimitive
}

"Prints nodes in an readable format"
class NodePrinter(WorkingTreeNode node) {
	
	"Prints the node recursively as string
	 to the given builder with the given start indentation."
	void printTree(Node node, StringBuilder b, Integer indent) {
		b.append(" ".repeat(indent));
		b.append(node.children.empty then "-" else "+");
		b.append(" ``node.name``");
		b.append(" (``node.storeId``)\n");
		
		for(name -> prop in node.properties) {
			b.append(" ".repeat(indent + 2));
			b.append("* ``name``: ");
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