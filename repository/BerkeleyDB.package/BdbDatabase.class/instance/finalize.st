finalization
finalize

	self isValid ifTrue: [self prim: {nil.nil} dbClose: self dbHandle]