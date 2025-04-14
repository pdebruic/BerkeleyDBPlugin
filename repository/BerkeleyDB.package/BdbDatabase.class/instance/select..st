enumeration
select: aBlock 
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!"

	"Evaluate aBlock with each of my values as the argument. Collect into a
	new dictionary, only those associations for which aBlock evaluates to
	true."

	| newCollection |
	newCollection _ Dictionary new.
	self associationsDo: 
		[:each | 
		(aBlock value: each value) ifTrue: [newCollection add: each]].
	^newCollection