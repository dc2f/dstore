
import com.dstore {
	Property,
	PropertyPrimitive
}

import java.lang {
	JString=String,
	StringBuilder
}
import java.nio {
	ByteBuffer {
		allocateByteBuffer=allocate
	},
	ByteOrder {
		littleEndian=LITTLE_ENDIAN
	}
}
import java.security {
	MessageDigest {
		createDigest=getInstance
	}
}

String hexDigits = "0123456789abcdef";
Integer twoByteMask = #F;

"Create sha1 keys"
shared class Sha1() {
	
	MessageDigest digest = createDigest("SHA1");
	ByteBuffer buf = allocateByteBuffer(8).order(littleEndian);
	
	void flush() {
		digest.digest(buf.array());
		buf.reset();
	}
	
	"Adds a property to the hash.
	 
	 Returns `this` for chaining"
	shared Sha1 add(Property property) {
		if(is String property) {
			digest.update(JString(property).getBytes("UTF-8"));
		} else if (is Integer property) {
			buf.putLong(property);
			flush();
		} else if (is Float property) {
			buf.putDouble(property);
			flush();
		} else if (is {PropertyPrimitive*} property) {
			for(item in property) {
				add(item);
			}
		}
		
		return this;
	}
	
	"Resets the hasher to start a new hash.
	 
	 Returns `this` for chaining"
	shared Sha1 reset() {
		digest.reset();
		return this;
	}

	"Get the current hasher state as 64 character hex string"
	shared actual String string {
		value bytes = digest.digest();
		value builder = StringBuilder(64);
		for(Integer byte in bytes.array) {
			value first = hexDigits[byte.rightLogicalShift(4).and(twoByteMask)];
			value second = hexDigits[byte.and(twoByteMask)];
			assert (exists first, exists second);
			
			builder.append(first).append(second);
		}
		
		return builder.string;
	}
}