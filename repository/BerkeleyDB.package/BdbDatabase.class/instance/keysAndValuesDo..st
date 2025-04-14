enumeration
keysAndValuesDo: aBlock
	"WARNING: If you have a large database this could take a long time!"

	^self associationsDo:[:assoc|
		aBlock value: assoc key value: assoc value].