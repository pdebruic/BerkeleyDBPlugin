accessing
at: bytes

	^self at: bytes ifAbsent: [self errorKeyNotFound]

	