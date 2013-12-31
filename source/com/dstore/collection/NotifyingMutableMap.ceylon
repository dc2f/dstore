import ceylon.collection { MutableMap, HashMap }


"A simple wrapper MutableMap which calls afterChange after put/putAll/remove/clear."
shared class NotifyingMutableMap<Key, Item>(wrapped, afterChange) satisfies MutableMap<Key, Item> 
		given Key satisfies Object
		given Item satisfies Object {
	
	MutableMap<Key, Item> wrapped;
	Anything () afterChange;

	shared actual void clear() {
		wrapped.clear();
		afterChange();
	}
	
	shared actual Map<Key,Item> clone => NotifyingMutableMap<Key, Item>(HashMap<Key, Item>(wrapped), afterChange);
	
	shared actual Item? get(Object key) => wrapped.get(key);
	
	shared actual Iterator<Key->Item> iterator() => wrapped.iterator();
	
	shared actual Item? put(Key key, Item item) {
		Item? tmp = wrapped.put(key, item);
		afterChange();
		return tmp;
	}
	
	shared actual void putAll({<Key->Item>*} entries) {
		wrapped.putAll(entries);
		afterChange();
	}
	
	shared actual Item? remove(Key key) {
		value tmp = wrapped.remove(key);
		afterChange();
		return tmp;
	}
	
	shared actual Boolean equals(Object that) => wrapped.equals(that);
	
	shared actual Integer hash => wrapped.hash;
	

}