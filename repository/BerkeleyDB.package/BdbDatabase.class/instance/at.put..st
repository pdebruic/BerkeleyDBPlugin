accessing
at: key put: value

	| result |
	result := self prim: {nil.nil} db: self dbHandle at: key put: value.
	result first = 0 ifTrue: [^value].
	^self primitiveResultError: result
