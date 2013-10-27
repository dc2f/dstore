import ceylon.collection { MutableMap }

shared interface NonNullableMap<Key, Item> satisfies Map<Key, Item>
		given Key satisfies Object
		given Item satisfies Object {
	
	
	shared formal actual Item get(Object key);
	
}
