maintenance
commit

	| result |
	result := self prim: {nil.nil} dbCommit: self dbHandle.
	result first ~= 0 ifTrue: [self primitiveResultError: result].