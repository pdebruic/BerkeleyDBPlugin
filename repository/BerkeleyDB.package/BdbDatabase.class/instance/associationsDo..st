enumeration
associationsDo: aBlock
	"WARNING: If you have a large database this could take a long time!"
	"Note, prim:dbcNext: automatically closes the cursor when the end is reached"

	| result cursor |
	result := self prim: {nil.nil} dbCursor: self dbHandle.
	result first ~= 0 ifTrue: [^self primitiveResultError: result].
	cursor := result second.
	[(result := self prim: {nil.nil.nil} dbcNext: cursor) first = 0 ] 
		whileTrue:
			[aBlock value: (Association key: result second value: result third)].
	self prim: {nil.nil} dbcClose: cursor.

	result first ~= 1 ifTrue: 
		["Something other than the last record cause the loop to terminate"
		self primtiveResultError: result]. 
