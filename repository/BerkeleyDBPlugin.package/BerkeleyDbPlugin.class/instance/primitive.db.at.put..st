primitives
primitive: result db: dbOop at: key put: value
	| db keySize valueSize keyPtr valuePtr rCode errOop errmsg |
	self var: #db declareC: 'Database *db'.
	self var: #keyPtr declareC: 'void *keyPtr'.
	self var: #valuePtr declareC: 'void *valuePtr'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbAtPut' parameters: #(Oop Oop Oop Oop).
	db := self dbValueOf: dbOop.

	"Validate any parameters"
	interpreterProxy success: ((interpreterProxy isIntegerObject: key) not 
		and: [(interpreterProxy isIntegerObject: value) not]).
	interpreterProxy failed ifFalse:
		[interpreterProxy success: (interpreterProxy isBytes: key).
		interpreterProxy success: (interpreterProxy isBytes: value)].

	interpreterProxy failed ifFalse:
		[keySize := interpreterProxy slotSizeOf: key.
		valueSize := interpreterProxy slotSizeOf: value.
		keyPtr := interpreterProxy firstIndexableField: key.
		valuePtr := interpreterProxy firstIndexableField: value].
	interpreterProxy failed ifFalse:
		[rCode := self cCode: 'sqDbAtPut(db, keyPtr, keySize, valuePtr, valueSize, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result
