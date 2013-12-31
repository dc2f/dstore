/*
import ceylon.collection {
	HashMap,
	MutableMap
}

import com.dstore {
	Property
}

"A map for node properties that dirts the node on a property change"
shared class PropertyMap(Map<String, Property> loadedProperties) 
		satisfies MutableMap<String, Property> {
	
	value properties = HashMap<String, Property>(loadedProperties);
	shared late WorkingTreeNode node;
	
	shared actual void clear() {
		if(!properties.empty) {
			properties.clear();
			node.dirtProperties();
		}
	}
	
	shared actual Property? put(String key, Property item) {
		node.dirtProperties();
		return properties.put(key, item);
	}
	
	shared actual void putAll({<String->Property>*} entries) {
		node.dirtProperties();
		properties.putAll(entries);
	}
	
	shared actual Property? remove(String key) {
		if(properties.defines(key)) {
			node.dirtProperties();
			return properties.remove(key);
		}
		return null;
	}
	
	shared actual Map<String,Property> clone {
		value clone = PropertyMap(properties);
		clone.node = this.node;
		return clone;
	}
	
	shared actual Property? get(Object key) => properties.get(key);
	
	shared actual Iterator<String->Property> iterator() => properties.iterator();
	
	shared actual Boolean equals(Object that) {
		if(is PropertyMap that) {
			return properties.equals(that.properties);
		}
		return false;
	}
	
	shared actual Integer hash => properties.hash;
}
*/