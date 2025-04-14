instance creation
onExistingFileNamed: fileName
	"This method will open an existing database, or throw an exception if the database
	file does not exist."

	^self open: fileName create: false