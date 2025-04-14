instance creation
onFileNamed: fileName
	"This method will open an existing database or create a new one if fileName does
	not exist."

	^self open: fileName create: true