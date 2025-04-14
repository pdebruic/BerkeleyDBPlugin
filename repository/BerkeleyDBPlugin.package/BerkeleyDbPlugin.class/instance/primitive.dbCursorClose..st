primitives
primitive: result dbCursorClose: dbcOop
	| dbc errmsg rCode errOop |
	self var: #dbc declareC: 'DbCursor *dbc'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbCursorClose' parameters: #(Oop Oop).
	dbc := self dbcValueOf: dbcOop.

	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbCursorClose(dbc, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result