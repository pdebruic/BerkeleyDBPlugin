maintenance
verify

	| result |
	result := self prim: {nil.nil} dbVerify: self dbHandle.
	result first ~= 0 ifTrue: [self primitiveResultError: result]