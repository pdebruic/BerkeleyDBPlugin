removing
removeKey: key ifAbsent: aBlock

	| result |
	result := self prim: {nil.nil} db: self dbHandle removeKey: key.
	result first = 0 ifTrue: [^self].
	result first = 1 ifTrue: [^aBlock value].
	self primitiveResultError: result.
