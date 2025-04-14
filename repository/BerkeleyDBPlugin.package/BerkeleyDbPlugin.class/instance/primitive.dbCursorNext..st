primitives
primitive: result dbCursorNext: dbcOop
	| dbc key keySize value valueSize keyOop valueOop errmsg rCode errOop |
	self var: #dbc declareC: 'DbCursor *dbc'.
	self var: #key declareC: 'void *key'.
	self var: #value declareC: 'void *value'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbCursorNext' parameters: #(Oop Oop).
	dbc := self dbcValueOf: dbcOop.

	interpreterProxy failed ifTrue: [self cCode: 'fprintf(stderr,"got failure at 1\n")'].
	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbCursorNext(dbc, &key, &keySize, &value, &valueSize, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = 0 ifTrue:
			[self remapOop: result in: 
				[keyOop _ interpreterProxy 
					instantiateClass: interpreterProxy classByteArray 
					indexableSize: keySize].
			self remapOop: #(result keyOop) in: 
				[valueOop _ interpreterProxy 
					instantiateClass: interpreterProxy classByteArray 
					indexableSize: valueSize].
			self cCode: 'memcpy((void*) (keyOop + 4), key, keySize)'.
			self cCode: 'memcpy((void*) (valueOop + 4), value, valueSize)'.
			result stAt: 2 put: keyOop.
			result stAt: 3 put: valueOop].
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result