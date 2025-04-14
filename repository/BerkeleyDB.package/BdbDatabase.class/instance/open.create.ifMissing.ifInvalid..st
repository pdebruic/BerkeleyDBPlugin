initialization
open: name create: createFlag ifMissing: missingBlock ifInvalid: invalidBlock

	| result |
	result := self prim: (Array new: 2) dbOpen: name create: createFlag.
	(result at: 1) = 0 
		ifTrue:
			[self dbHandle: (result at: 2).
			self fileName: name.
			self isValid ifTrue: [self register]]
		ifFalse: 
			[(FileStream isAFileNamed: name) 
				ifTrue: [^invalidBlock value]
				ifFalse: [^missingBlock value].
			^self primitiveResultError: result].
