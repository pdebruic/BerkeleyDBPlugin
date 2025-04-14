accessing
associationAt: key ifAbsent: aBlock
	"Answer the association with the given key.
	If key is not found, return the result of evaluating aBlock.  Note, unlike a dictionary,
	this method will answer a new instance of Association on every call (since the database doesn't
	really store Association instances)."

	| val |
	val := self at: key ifAbsent: [^aBlock value].
	^Association key: key value: val