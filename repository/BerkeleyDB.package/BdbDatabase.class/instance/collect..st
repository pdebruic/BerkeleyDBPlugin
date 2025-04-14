enumeration
collect: aBlock 
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!"

	"Evaluate aBlock with each of my values as the argument.  Collect the
	resulting values into a collection that is like me. Answer with the new
	collection."
	| newCollection |
	newCollection _ OrderedCollection new: self size.
	self do: [:each | newCollection add: (aBlock value: each)].
	^ newCollection