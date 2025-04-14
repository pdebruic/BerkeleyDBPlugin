removing
keysAndValuesRemove: keyValueBlock
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!"

	"Removes all entries for which keyValueBlock returns true."
	"Unlike the Dictionary's counterpart, with databases it does not cause problems to
	remove items as you are iterating over the database.  Therefore, this method 
	removes the items as it goes, saving time and space (important for large databases!)."

	self associationsDo:
		[:assoc | (keyValueBlock value: assoc key value: assoc value)
			ifTrue: [self removeKey: assoc key]].
