import com.dstore.collection { LazyTransformingMap }

class WrappedString(wrapped) {
	String wrapped;
}

LazyTransformingMap<String, {String+}, {WrappedString+}, {WrappedString*}> children = LazyTransformingMap<String, {String+}, {WrappedString+}, {WrappedString*}> {
	{WrappedString+} transform({String+} keys) {
		{WrappedString+} ret = keys.map((String key) => WrappedString(key));
		return ret;
		//return self.workingTree.getNodeByStoreId(key, self);
	}
	defaultValue = {};
	initialItems = {"blubb"->{"blubber"}};
};


void testrun() {
	print("Hello World.");
	children.put("keytarget", {WrappedString("valuetarget")});
	print("keyinput: ``children.get("keytarget")``");
	children.put("keyinput", {"valueinput"});
	print("valueinput: ``children.get("keyinput")``");
}