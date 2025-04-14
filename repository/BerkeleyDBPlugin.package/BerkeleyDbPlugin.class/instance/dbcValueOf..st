primitives
dbcValueOf: oop
	"Return a pointer to the first byte of the async file record within the given Smalltalk bytes object, or nil if oop is not an async file record."

	self returnTypeC: 'DbCursor *'.
	interpreterProxy success:
		((interpreterProxy isIntegerObject: oop) not and:
		 [(interpreterProxy isBytes: oop) and:
		 [(interpreterProxy slotSizeOf: oop) = (self cCode: 'sizeof(DbCursor)')]]).
	interpreterProxy failed ifTrue: [^ nil].
	^ self cCode: '(DbCursor *) (oop + 4)'
