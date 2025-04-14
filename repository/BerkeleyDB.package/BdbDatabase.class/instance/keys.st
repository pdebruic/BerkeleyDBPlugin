accessing
keys
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!"

	| aSet |
	aSet _ Set new.
	self keysDo: [:key | aSet add: key].
	^ aSet