primitives
sqDbMalloc: size
	"Allocate a byte array of size bytes and return a pointer to the first field.  This 
	function is provided for use by the database implementation for returning data 
	associated with a given key.  This serves two purposes, a) the database implementation
	can use this function to allocate a buffer for returned data where the size of that 
	data is not known in advance of the call, and b) the database implementation can write
	directly into the object memory, eliminating the need to copy the data into a Smalltalk
	byte array at a later time."
	<export: true>
	| oop |
	self returnTypeC: 'void *'.
	oop := interpreterProxy instantiateClass: interpreterProxy classByteArray indexableSize: size.
	^self cCode: '(void *) (oop + 4)'

