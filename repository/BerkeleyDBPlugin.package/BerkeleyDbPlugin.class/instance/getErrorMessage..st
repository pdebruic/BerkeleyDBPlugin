primitive support
getErrorMessage: cptr
	"Convert the error message pointed to by cptr to a Smalltalk string."

	<inline: true>
	<var: 'aCString' type: 'const char *'>
	^self stringFromCString: cptr
