error handling
primitiveResultError: result

	result first = 100 ifTrue: [^self error: 'memory allocation error'].
	result first = 99 ifTrue: [^self error: 'invalid db handle'].
	result first = 98 ifTrue: [^self error: 'invalid cursor handle'].
	result first = -1 ifTrue: [^self error: result second].
	^self error: 'invalid result from primitive'