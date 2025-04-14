primitives
initialiseModule
	"Initialise the module"
	self export: true.
	^self cCode: 'sqDbInit(sqDbMalloc)' inSmalltalk:[true]