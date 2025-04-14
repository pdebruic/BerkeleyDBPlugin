Instances of me are interfaces to an underlying Berekeley DB database.  Here are a couple of instantiation examples:

	BdbDatabase onNewFileNamed: 'testing.db'
	BdbDatabase onExistingFileNamed: 'testing.db'
	BdbDatabase onFileNamed: 'testing.db'

Once you have an instance, you can do the usual Dictionary things with it:

	aDb at: 'fruit' put: 'apple'
	(aDb at: 'fruit') asString
	aDb associationsDo: [ :assn | Transcript show: (assn key asString, ' -> ', assn value asString); cr ]
	aDb keys
	aDb values

To actually commit data to disk (Berkeley DB maintains its own cache):

	aDb commit
 