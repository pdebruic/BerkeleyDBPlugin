primitives
primitiveDbIsValid: dbOop
	| db ret |
	self var: #db declareC: 'Database *db'.
	self primitive: 'primitiveDbIsValid' parameters: #(Oop).
	db := self dbValueOf: dbOop.
	interpreterProxy failed ifFalse: [ret := self sqDbIsValid: db].
	^ret asBooleanObj
