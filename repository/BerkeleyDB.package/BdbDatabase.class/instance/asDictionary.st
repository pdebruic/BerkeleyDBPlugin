conversion
asDictionary
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory."

	| tmp |
	tmp := Dictionary new.
	self associationsDo: [ :assn | tmp add: assn ].
	^tmp