primitives
primitive: result dbCursor: dbOop
	| db dbc dbcOop rCode errOop errmsg |
	self var: #db declareC: 'Database *db'.
	self var: #dbc declareC: 'DbCursor *dbc'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbCursor' parameters: #(Oop Oop).

	interpreterProxy failed ifFalse:
		[self remapOop: #(result dbOop) in: 
			[dbcOop := interpreterProxy 
				instantiateClass: interpreterProxy classByteArray 
				indexableSize: self dbcRecordSize]].

	interpreterProxy failed ifFalse:
		[db := self dbValueOf: dbOop.
		dbc := self dbcValueOf: dbcOop].

	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbCursor(db, dbc, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = 0 ifTrue: [result stAt: 2 put: dbcOop].
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result
