primitives
dbcRecordSize
	"Return the size of a Smalltalk socket record in bytes."

	^ self cCode: 'sizeof(DbCursor)' inSmalltalk: [8]