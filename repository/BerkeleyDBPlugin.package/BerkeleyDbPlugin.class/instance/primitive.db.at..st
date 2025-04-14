primitives
primitive: result db: dbOop at: key
	| db keySize keyPtr value valueSize errOop errmsg rCode |
	self var: #db declareC: 'Database *db'.
	self var: #keyPtr declareC: 'void *keyPtr'.
	self var: #value declareC: 'void *value'.
	self var: #valueSize declareC: 'int valueSize'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbAt' parameters: #(Oop Oop Oop).
	db := self dbValueOf: dbOop.

	"Validate any parameters"
	interpreterProxy success: ((interpreterProxy isIntegerObject: key) not 
		and: [interpreterProxy isBytes: key]).

	interpreterProxy failed ifFalse:
		[keySize := interpreterProxy slotSizeOf: key.
		keyPtr := interpreterProxy firstIndexableField: key].
	interpreterProxy failed ifFalse:
		["BEWARE: we assume that sqDbAt will not access the key data after it allocates 
		space for the result...to do so would be dangerous as the sqDbMalloc callback 
		to allocate space for the result can trigger GC and potentially move the key data!  
		This might not crash the system, but may simply result in the key not being 
		found, or it finding the wrong data."

		self remapOop: result in:
			[rCode := self cCode: 'sqDbAt(db, keyPtr, keySize, &value, &valueSize, &errmsg)'.
			rCode = -1 ifTrue: [errOop := self getErrorMessage: errmsg]].
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = 0 ifTrue: [result stAt: 2 put: value cPtrAsOop].
		rCode = -1 ifTrue: [result stAt: 2 put: errOop]].

	^result
