maintenance
isValid
	"<Boolean> Answer whether or not dbHandle is valid.  This method does not indicate
	whether or not the underlying database is valid (handles do not remain valid across 
	Squeak sessions).  If you have an invalid handle, you may simple request a new one 
	by sending #refreshDbHandle (which will work providing that the instance variable 
	'fileName' points to a valid database file)."

	self dbHandle ifNil: [^false].
	^self primDbIsValid: self dbHandle