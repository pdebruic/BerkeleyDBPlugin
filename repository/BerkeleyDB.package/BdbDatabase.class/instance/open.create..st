initialization
open: name create: createFlag

	^self
		open: name
		create: createFlag
		ifMissing: [self error: 'Invalid database file']
		ifInvalid: [self error: 'Invalid database file']
