instance creation
onNewFileNamed: fileName
	"This method will create a new database file, or throw an exception if the file
	already exists."

	^(FileStream isAFileNamed: fileName)
		ifTrue: [(FileExistsException fileName: fileName fileClass: self) signal]
		ifFalse: [self open: fileName create: true].
