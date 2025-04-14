primitives
primitive: result dbOpen: fileName create: createFlag
	| fileNamePtr fileNameSize dbOop db errmsg rCode errOop |
	self var: #db declareC: 'Database *db'.
	self var: #fileNamePtr declareC: 'char *fileNamePtr'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbOpen' parameters: #(Oop Oop Boolean).

	"Validate any parameters"
	interpreterProxy success: (interpreterProxy isBytes: fileName).

	interpreterProxy failed ifFalse:
		[self remapOop: fileName in:
			[dbOop _ interpreterProxy 
				instantiateClass: interpreterProxy classByteArray 
				indexableSize: self dbRecordSize].
		db := self dbValueOf: dbOop].

	fileNamePtr := interpreterProxy firstIndexableField: fileName.
	fileNameSize := interpreterProxy slotSizeOf: fileName.

	interpreterProxy failed ifFalse:
		[rCode := self cCode: 'sqDbOpen(db, fileNamePtr, fileNameSize, createFlag, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = 0 ifTrue: [result stAt: 2 put: dbOop]].
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop].
	^result