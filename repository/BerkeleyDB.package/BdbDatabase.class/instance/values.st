accessing
values
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!"

	"Answer a Collection containing the receiver's values."
	| out |
	out _ WriteStream on: (Array new: 20).
	self valuesDo: [:value | out nextPut: value].
	^ out contents