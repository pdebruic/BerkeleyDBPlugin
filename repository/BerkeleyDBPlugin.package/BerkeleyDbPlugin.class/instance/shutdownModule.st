primitives
shutdownModule
	"Initialise the module"
	self export: true.
	^self cCode: 'sqDbShutdown()' inSmalltalk:[true]