initialization
refreshDbHandle

	self unregister.
	self open: self fileName create: false
