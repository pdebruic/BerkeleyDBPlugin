primitives
dbValueOf: oop
	"Return a pointer to the first byte of the async file record within the given Smalltalk bytes object, or nil if oop is not an async file record."

	self returnTypeC: 'Database *'.
	interpreterProxy success:
		((interpreterProxy isIntegerObject: oop) not and:
		 [(interpreterProxy isBytes: oop) and:
		 [(interpreterProxy slotSizeOf: oop) = (self cCode: 'sizeof(Database)')]]).
	interpreterProxy failed ifTrue: [^ nil].
	^ self cCode: '(Database *) (oop + 4)'
