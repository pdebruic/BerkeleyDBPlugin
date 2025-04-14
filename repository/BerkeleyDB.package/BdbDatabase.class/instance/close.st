maintenance
close

	| result |
	self unregister.
	result := self prim: {nil.nil} dbClose: self dbHandle.
	result first ~= 0 ifTrue: [self primitiveResultError: result].
