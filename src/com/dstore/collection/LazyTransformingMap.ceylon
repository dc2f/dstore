import ceylon.collection {
	HashMap, MutableMap
}
import ceylon.language.meta { type }
import com.dstore { Node }

"A mutable map that lazily transforms from the input values to target value upon read.
 
 The target values are cached, so the given transforming function must be stable."
shared class LazyTransformingMap<Key, InputValue, TargetValue, DefaultValue>(transform, defaultValue, {<Key->InputValue|TargetValue>*} initialItems = emptyMap) 
		satisfies MutableMap<Key, InputValue|DefaultValue> & NonNullableMap<Key, DefaultValue> 
		given Key satisfies Object
		given DefaultValue satisfies Object 
		given InputValue satisfies Object
		given TargetValue satisfies DefaultValue {
	
	TargetValue (InputValue) transform;
	
	DefaultValue defaultValue;
	
	shared HashMap<Key, TargetValue|InputValue> mixed = HashMap<Key, TargetValue|InputValue>(initialItems);
	
	shared actual Boolean equals(Object that) => mixed.equals(that);
	
	shared actual Integer hash => mixed.hash;
	
	shared actual LazyTransformingMap<Key, InputValue, TargetValue, DefaultValue> clone {
		value cloned = LazyTransformingMap<Key, InputValue, TargetValue, DefaultValue>(transform, defaultValue, initialItems);
		cloned.mixed.putAll(mixed.clone);
		return cloned;
	}
	
	shared actual Iterator<Key->TargetValue> iterator() {
		value keyIterator = mixed.keys.iterator();
		
		object iterator satisfies Iterator<Key->TargetValue> {
			shared actual <Key->TargetValue>|Finished next() {
				if(!is Finished name = keyIterator.next()) {
					value item = get(name);
					// we only iterate over existing keys. can never be DefaultValue.
					print("item: ``name``: ``item``: ``outer.mixed``");
					assert (is TargetValue item);
					return name -> item; 
				}
				return finished;
			}
		}
		
		return iterator;
	}
	
	shared actual DefaultValue get(Object key) {
		value element = mixed.get(key);
		if(is TargetValue element) {
			print("is TargetValue");
			return element;
		} else if (is InputValue element) {
			print("is InputValue");
			assert (is Key key);
			value transformed = transform(element);
			mixed.put(key, transformed);
			return transformed;
		}
		//print("type: ``type(element)``");
		return defaultValue;
	}
	
	shared actual Boolean empty => mixed.empty;
	
	"Adds an element into this map"
	shared actual InputValue|TargetValue? put(Key key, InputValue|DefaultValue item) {
		if (is TargetValue|InputValue item) {
			return mixed.put(key, item);
		}
		return null;
	}
	
	"Adds all elemnts into this map"
	shared actual void putAll({<Key->InputValue|DefaultValue>*} items) {
		if (is {<Key->InputValue|TargetValue>*} items) {
			mixed.putAll(items);
		}
	}
	
	"Removes an item of this map"
	shared actual InputValue|TargetValue? remove(Key key) {
		return mixed.remove(key);
	}
	
	"Clears all items in the map"
	shared actual void clear() {
		mixed.clear();
	}
}