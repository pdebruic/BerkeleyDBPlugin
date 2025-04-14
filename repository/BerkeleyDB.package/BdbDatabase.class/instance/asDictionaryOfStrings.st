conversion
asDictionaryOfStrings
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory."

	| tmp |
	tmp := Dictionary new.
	self associationsDo: [ :assn | tmp at: assn key asString put: assn value asString ].
	^tmp