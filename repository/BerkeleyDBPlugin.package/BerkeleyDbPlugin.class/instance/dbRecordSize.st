primitives
dbRecordSize
	"Return the size of a Smalltalk socket record in bytes."

	^ self cCode: 'sizeof(Database)' inSmalltalk: [8]