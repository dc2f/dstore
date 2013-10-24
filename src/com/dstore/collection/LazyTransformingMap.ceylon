import ceylon.collection {
	HashMap, MutableMap
}

"A mutable map that lazily transforms from the input values to target value upon read.
 
 The target values are cached, so the given transforming function must be stable."
class LazyTransformingMap<Key, TargetValue, InputValue>(transform, {<Key->InputValue|TargetValue>*} initialItems = emptyMap) 
		satisfies Map<Key, TargetValue> 
		given Key satisfies Object
		given TargetValue satisfies Object 
		given InputValue satisfies Object {
	
	TargetValue (InputValue) transform;
	
	HashMap<Key, TargetValue|InputValue> mixed = HashMap<Key, TargetValue|InputValue>();
	
	shared actual Boolean equals(Object that) => mixed.equals(that);
	
	shared actual Integer hash => mixed.hash;
	
	shared actual Map<Key,TargetValue> clone {
		value cloned = LazyTransformingMap<Key, TargetValue, InputValue>(transform, initialItems);
		cloned.mixed.putAll(mixed.clone);
		return cloned;
	}
	
	shared actual Iterator<Key->TargetValue> iterator() {
		value keyIterator = mixed.keys.iterator();
		
		object iterator satisfies Iterator<Key->TargetValue> {
			shared actual <Key->TargetValue>|Finished next() {
				if(!is Finished name = keyIterator.next()) {
					value item = get(name);
					assert(exists item);
					
					return name -> item; 
				}
				return finished;
			}
		}
		
		return iterator;
	}
	
	shared actual TargetValue? get(Object key) {
		value element = mixed.get(key);
		if(is TargetValue element) {
			return element;
		} else if (is InputValue element) {
			assert (is Key key);
			value transformed = transform(element);
			mixed.put(key, transformed);
			return transformed;
		}
		return null;
	}
	
	"Adds an element into this map"
	shared void put(Key key, InputValue|TargetValue item) {
		mixed.put(key, item);
	}
	
	"Adds all elemnts into this map"
	shared void putAll(Key key, {<Key->InputValue|TargetValue>*} items) {
		mixed.putAll(items);
	}
	
	"Removes an item of this map"
	shared void remove(Key key) {
		mixed.remove(key);
	}
	
	"Clears all items in the map"
	shared void clear() {
		mixed.clear();
	}
}