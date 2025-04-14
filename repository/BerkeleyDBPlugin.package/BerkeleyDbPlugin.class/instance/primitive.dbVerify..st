primitives
primitive: result dbVerify: dbOop
	| db errmsg rCode errOop |
	self var: #db declareC: 'Database *db'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbVerify' parameters: #(Oop Oop).
	db := self dbValueOf: dbOop.

	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbVerify(db, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result
