import ceylon.json {
	...
}

import com.dstore {
	Property, PropertyPrimitive
}
import ceylon.collection { HashMap }

shared class JsonConverter() {
	
	Map<String, String> parseStringMap(String json) {
		value parsed = parse(json);
		value map = HashMap<String, String>();
		for(name -> item in parsed) {
			if(is String item) {
				map.put(name, item);
			}
		}
		return map;
	}
	
	String serializeStringMap(Map<String, String> map) {
		value obj = Object();
		for(name -> item in map) {
			obj.put(name, item);
		}
		return obj.string;
	}
	
	shared FlatStoredNode parseFlatStoredNode(String json) {
		value parsed = parse(json);
		return FlatStoredNode { 
			storedId = parsed.getString("storedId"); 
			name = parsed.getString("name"); 
			childrenId = parsed.getStringOrNull("childrenId"); 
			propertiesId = parsed.getStringOrNull("propertiesId"); 
		};
	}
	
	shared String serializeFlatStoredNode(FlatStoredNode node) {
		value obj = Object();
		obj.put("storedId", node.storedId);
		obj.put("name", node.name);
		if(exists childrenId = node.childrenId) {
			obj.put("childrenId", childrenId);
		}
		if(exists propertiesId = node.propertiesId) {
			obj.put("propertiesId", propertiesId);
		}
		return obj.string;
	}
	
	shared Map<String, Property> parseProperties(String json) {
		value parsed = parse(json);
		value properties = HashMap<String, Property>();
		for(name -> item in parsed) {
			if(is Property item) {
				properties.put(name, item);
			}
		}
		return properties;
	}
	
	shared String serializeProperties(Map<String, Property> properties) {
		value obj = Object();
		for(name -> property in properties) {
			switch(property)
			case(is PropertyPrimitive) {
				
			}
			case(is Iterable<PropertyPrimitive>) {
				
			}
		}
		return obj.string;
	}
	
	shared Map<String, String> parseChildren(String json) {
		return parseStringMap(json);
	}
	
	shared String serializeChildren(Map<String, String> children) {
		return serializeStringMap(children);
	}
}