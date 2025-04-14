primitives
primitive: result dbCommit: dbOop
	| db rCode errOop errmsg |
	self var: #db declareC: 'Database *db'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbCommit' parameters: #(Oop Oop).
	db := self dbValueOf: dbOop.

	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbCommit(db, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result