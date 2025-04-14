primitives
primitive: result db: dbOop removeKey: key
	| db keySize keyPtr rCode errOop errmsg |
	self var: #db declareC: 'Database *db'.
	self var: #keyPtr declareC: 'void *keyPtr'.
	self var: #value declareC: 'void *value'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbRemoveKey' parameters: #(Oop Oop Oop).
	db := self dbValueOf: dbOop.

	"Validate parameters"
	interpreterProxy success: (interpreterProxy isBytes: key).

	interpreterProxy failed ifFalse:
		[keySize := interpreterProxy slotSizeOf: key.
		keyPtr := interpreterProxy firstIndexableField: key].
	interpreterProxy failed ifFalse:
		[rCode := self cCode: 'sqDbRemoveKey(db, keyPtr, keySize, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result

