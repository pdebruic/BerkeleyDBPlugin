accessing
at: bytes ifAbsent: aBlock

	| result |
	result := self prim: {nil.nil} db: self dbHandle at: bytes.
	result first = 0 ifTrue: [^result second].
	result first = 1 ifTrue: [^aBlock value].
	self primitiveResultError: result.

