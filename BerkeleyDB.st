Smalltalk organization addCategory: 'BerkeleyDB'!

Object subclass: #BdbDatabase
	instanceVariableNames: 'dbHandle fileName '
	classVariableNames: 'Registry '
	poolDictionaries: ''
	category: 'BerkeleyDB'!

BdbDatabase class
	instanceVariableNames: ''!

TestInterpreterPlugin subclass: #BerkeleyDbPlugin
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'BerkeleyDB'!

BerkeleyDbPlugin class
	instanceVariableNames: ''!

!BdbDatabase commentStamp: 'svp 12/3/2002 09:33' prior: 0!
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
 !

!BerkeleyDbPlugin commentStamp: 'svp 5/24/2002 16:50' prior: 0!
DatabasePlugin translateDoInlining: true!

!BdbDatabase methodsFor: 'conversion' stamp: 'svp 6/5/2002 15:21'!
asDictionary
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory."

	| tmp |
	tmp := Dictionary new.
	self associationsDo: [ :assn | tmp add: assn ].
	^tmp! !

!BdbDatabase methodsFor: 'conversion' stamp: 'svp 6/5/2002 15:21'!
asDictionaryOfStrings
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory."

	| tmp |
	tmp := Dictionary new.
	self associationsDo: [ :assn | tmp at: assn key asString put: assn value asString ].
	^tmp! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 6/5/2002 15:27'!
associationAt: key 
	^ self associationAt: key ifAbsent: [self errorKeyNotFound]! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 6/5/2002 15:27'!
associationAt: key ifAbsent: aBlock
	"Answer the association with the given key.
	If key is not found, return the result of evaluating aBlock.  Note, unlike a dictionary,
	this method will answer a new instance of Association on every call (since the database doesn't
	really store Association instances)."

	| val |
	val := self at: key ifAbsent: [^aBlock value].
	^Association key: key value: val! !

!BdbDatabase methodsFor: 'enumeration' stamp: 'svp 8/15/2002 14:30'!
associationsDo: aBlock
	"WARNING: If you have a large database this could take a long time!!"
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
! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 6/3/2002 16:35'!
at: bytes

	^self at: bytes ifAbsent: [self errorKeyNotFound]

	! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 8/15/2002 14:30'!
at: bytes ifAbsent: aBlock

	| result |
	result := self prim: {nil.nil} db: self dbHandle at: bytes.
	result first = 0 ifTrue: [^result second].
	result first = 1 ifTrue: [^aBlock value].
	self primitiveResultError: result.

! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 6/3/2002 16:41'!
at: key ifAbsentPut: aBlock 
	"Return the value at the given key. 
	If key is not included in the receiver store the result 
	of evaluating aBlock as new value."

	^ self at: key ifAbsent: [self at: key put: aBlock value]! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 6/5/2002 15:28'!
at: key ifPresent: aBlock
	"Lookup the given key in the receiver. If it is present, answer the value of evaluating the given block with the value associated with the key. Otherwise, answer nil."

	| v |
	v _ self at: key ifAbsent: [^ nil].
	^ aBlock value: v
! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 8/15/2002 14:30'!
at: key put: value

	| result |
	result := self prim: {nil.nil} db: self dbHandle at: key put: value.
	result first = 0 ifTrue: [^value].
	^self primitiveResultError: result
! !

!BdbDatabase methodsFor: 'maintenance' stamp: 'svp 8/15/2002 15:29'!
close

	| result |
	self unregister.
	result := self prim: {nil.nil} dbClose: self dbHandle.
	result first ~= 0 ifTrue: [self primitiveResultError: result].
! !

!BdbDatabase methodsFor: 'maintenance' stamp: 'svp 6/4/2002 14:04'!
closeAndDelete

	"WARNING: this method will close and delete the database from disk!!!!!!"

	self close.
	FileDirectory deleteFilePath: self fileName! !

!BdbDatabase methodsFor: 'enumeration' stamp: 'svp 6/5/2002 15:30'!
collect: aBlock 
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!!"

	"Evaluate aBlock with each of my values as the argument.  Collect the
	resulting values into a collection that is like me. Answer with the new
	collection."
	| newCollection |
	newCollection _ OrderedCollection new: self size.
	self do: [:each | newCollection add: (aBlock value: each)].
	^ newCollection! !

!BdbDatabase methodsFor: 'maintenance' stamp: 'svp 8/15/2002 15:34'!
commit

	| result |
	result := self prim: {nil.nil} dbCommit: self dbHandle.
	result first ~= 0 ifTrue: [self primitiveResultError: result].! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 5/30/2002 17:25'!
dbHandle

	^dbHandle! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 5/30/2002 17:25'!
dbHandle: aByteArray

	dbHandle := aByteArray! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 5/30/2002 13:47'!
dbRecordSize
	"Return the size of a Smalltalk socket record in bytes."

	^ self cCode: 'sizeof(Database)' inSmalltalk: [8]! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 5/24/2002 15:11'!
dbValueOf: oop
	"Return a pointer to the first byte of the async file record within the given Smalltalk bytes object, or nil if oop is not an async file record."

	self returnTypeC: 'Database *'.
	interpreterProxy success:
		((interpreterProxy isIntegerObject: oop) not and:
		 [(interpreterProxy isBytes: oop) and:
		 [(interpreterProxy slotSizeOf: oop) = (self cCode: 'sizeof(Database)')]]).
	interpreterProxy failed ifTrue: [^ nil].
	^ self cCode: '(Database *) (oop + 4)'
! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 6/5/2002 14:34'!
dbcRecordSize
	"Return the size of a Smalltalk socket record in bytes."

	^ self cCode: 'sizeof(DbCursor)' inSmalltalk: [8]! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 6/5/2002 14:34'!
dbcValueOf: oop
	"Return a pointer to the first byte of the async file record within the given Smalltalk bytes object, or nil if oop is not an async file record."

	self returnTypeC: 'DbCursor *'.
	interpreterProxy success:
		((interpreterProxy isIntegerObject: oop) not and:
		 [(interpreterProxy isBytes: oop) and:
		 [(interpreterProxy slotSizeOf: oop) = (self cCode: 'sizeof(DbCursor)')]]).
	interpreterProxy failed ifTrue: [^ nil].
	^ self cCode: '(DbCursor *) (oop + 4)'
! !

!BdbDatabase methodsFor: 'maintenance' stamp: 'svp 11/5/2002 16:24'!
delete

	"WARNING: this method will close and delete the database from disk!!!!!!"

	FileDirectory deleteFilePath: self fileName! !

!BdbDatabase methodsFor: 'enumeration' stamp: 'svp 6/5/2002 15:30'!
do: aBlock
	"WARNING: If you have a large database this could take a long time!!"

	self valuesDo: aBlock! !

!BdbDatabase methodsFor: 'error handling' stamp: 'svp 6/3/2002 16:22'!
errorKeyNotFound

	self error: 'key not found'! !

!BdbDatabase class methodsFor: 'private' stamp: 'svp 6/4/2002 15:32'!
fileExistsUserHandling: fullFileName
	| dir localName choice newName newFullFileName |
	dir _ FileDirectory forFileName: fullFileName.
	localName _ FileDirectory localNameFor: fullFileName.
	choice _ (PopUpMenu
		labels:
'overwrite that file\choose another name\cancel' withCRs)
		startUpWithCaption: localName, '
already exists.'.

	choice = 1 ifTrue: [
		dir deleteFileNamed: localName
			ifAbsent: [self error: 'Could not delete the old version of that file'].
		^ self open: fullFileName create: true].

	choice = 2 ifTrue: [
		newName _ FillInTheBlank request: 'Enter a new file name' initialAnswer: fullFileName.
		newFullFileName _ FileStream fullName: newName.
		^ self new: newFullFileName].

	self error: 'Please close this to abort file opening'! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 6/4/2002 10:40'!
fileName

	^fileName! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 6/4/2002 10:40'!
fileName: aString

	fileName := aString! !

!BdbDatabase methodsFor: 'finalization' stamp: 'svp 8/15/2002 15:30'!
finalize

	self isValid ifTrue: [self prim: {nil.nil} dbClose: self dbHandle]! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 8/14/2002 17:01'!
getErrorMessage: cptr

	| size oop |
	self inline: true.
	size := self cCode: 'strlen((char*) cptr)'.
	oop := interpreterProxy 
			instantiateClass: interpreterProxy classString 
			indexableSize: size.
	self cCode: 'memcpy((void*) (oop + 4), (void *) cptr, size)'.
	^oop
	! !

!BerkeleyDbPlugin class methodsFor: 'translation' stamp: 'svp 5/30/2002 10:49'!
hasHeaderFile
	"If there is a single intrinsic header file to be associated with the plugin, here is where you want to flag"
	^true! !

!BdbDatabase methodsFor: 'testing' stamp: 'svp 6/5/2002 15:29'!
includesKey: key 
	"Answer whether the receiver has a key equal to the argument, key."
	
	self at: key ifAbsent: [^false].
	^true! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 5/31/2002 17:06'!
initialiseModule
	"Initialise the module"
	self export: true.
	^self cCode: 'sqDbInit(sqDbMalloc)' inSmalltalk:[true]! !

!BdbDatabase methodsFor: 'maintenance' stamp: 'svp 6/4/2002 14:06'!
isValid
	"<Boolean> Answer whether or not dbHandle is valid.  This method does not indicate
	whether or not the underlying database is valid (handles do not remain valid across 
	Squeak sessions).  If you have an invalid handle, you may simple request a new one 
	by sending #refreshDbHandle (which will work providing that the instance variable 
	'fileName' points to a valid database file)."

	self dbHandle ifNil: [^false].
	^self primDbIsValid: self dbHandle! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 6/5/2002 15:23'!
keys
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!!"

	| aSet |
	aSet _ Set new.
	self keysDo: [:key | aSet add: key].
	^ aSet! !

!BdbDatabase methodsFor: 'enumeration' stamp: 'svp 6/5/2002 15:31'!
keysAndValuesDo: aBlock
	"WARNING: If you have a large database this could take a long time!!"

	^self associationsDo:[:assoc|
		aBlock value: assoc key value: assoc value].! !

!BdbDatabase methodsFor: 'removing' stamp: 'svp 6/5/2002 15:52'!
keysAndValuesRemove: keyValueBlock
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!!"

	"Removes all entries for which keyValueBlock returns true."
	"Unlike the Dictionary's counterpart, with databases it does not cause problems to
	remove items as you are iterating over the database.  Therefore, this method 
	removes the items as it goes, saving time and space (important for large databases!!)."

	self associationsDo:
		[:assoc | (keyValueBlock value: assoc key value: assoc value)
			ifTrue: [self removeKey: assoc key]].
! !

!BdbDatabase methodsFor: 'enumeration' stamp: 'svp 6/5/2002 15:24'!
keysDo: aBlock 
	"WARNING: If you have a large database this could take a long time!!"
	"Evaluate aBlock for each of the receiver's keys."

	self associationsDo: [:association | aBlock value: association key]! !

!BdbDatabase class methodsFor: 'instance creation' stamp: 'svp 12/3/2002 09:11'!
onExistingFileNamed: fileName
	"This method will open an existing database, or throw an exception if the database
	file does not exist."

	^self open: fileName create: false! !

!BdbDatabase class methodsFor: 'instance creation' stamp: 'svp 12/3/2002 09:10'!
onFileNamed: fileName
	"This method will open an existing database or create a new one if fileName does
	not exist."

	^self open: fileName create: true! !

!BdbDatabase class methodsFor: 'instance creation' stamp: 'svp 12/3/2002 09:11'!
onNewFileNamed: fileName
	"This method will create a new database file, or throw an exception if the file
	already exists."

	^(FileStream isAFileNamed: fileName)
		ifTrue: [(FileExistsException fileName: fileName fileClass: self) signal]
		ifFalse: [self open: fileName create: true].
! !

!BdbDatabase methodsFor: 'initialization' stamp: 'svp 10/23/2002 13:35'!
open: name create: createFlag

	^self
		open: name
		create: createFlag
		ifMissing: [self error: 'Invalid database file']
		ifInvalid: [self error: 'Invalid database file']
! !

!BdbDatabase class methodsFor: 'private' stamp: 'svp 5/30/2002 17:31'!
open: fileName create: bool

	^self new
		open: fileName create: bool;
		yourself! !

!BdbDatabase methodsFor: 'initialization' stamp: 'svp 10/23/2002 13:37'!
open: name create: createFlag ifMissing: missingBlock ifInvalid: invalidBlock

	| result |
	result := self prim: (Array new: 2) dbOpen: name create: createFlag.
	(result at: 1) = 0 
		ifTrue:
			[self dbHandle: (result at: 2).
			self fileName: name.
			self isValid ifTrue: [self register]]
		ifFalse: 
			[(FileStream isAFileNamed: name) 
				ifTrue: [^invalidBlock value]
				ifFalse: [^missingBlock value].
			^self primitiveResultError: result].
! !

!BdbDatabase methodsFor: 'error handling' stamp: 'svp 8/14/2002 10:36'!
pluginMissing

	^self error: 'DatabasePlugin is not available'! !

!BdbDatabase methodsFor: 'maintenance' stamp: 'svp 8/9/2002 16:49'!
prepare

	"There is nothing to do here...we assume that we are the only open connection
	to the database.  Under that assumption, all prepares are successful."

	^true! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:30'!
prim: result db: db at: key

	<primitive: 'primitiveDbAt' module: 'BerkeleyDbPlugin'>
	self primitiveFailed
! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:30'!
prim: result db: db at: key put: value

	<primitive: 'primitiveDbAtPut' module: 'BerkeleyDbPlugin'>
	self primitiveFailed
! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:30'!
prim: result db: db removeKey: key

	<primitive: 'primitiveDbRemoveKey' module: 'BerkeleyDbPlugin'>
	self primitiveFailed
! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:30'!
prim: result dbClose: db

	<primitive: 'primitiveDbClose' module: 'BerkeleyDbPlugin'>
	self primitiveFailed
! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:30'!
prim: result dbCommit: db

	<primitive: 'primitiveDbCommit' module: 'BerkeleyDbPlugin'>
	self primitiveFailed! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:30'!
prim: result dbCursor: db

	<primitive: 'primitiveDbCursor' module: 'BerkeleyDbPlugin'>
	self primitiveFailed
! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:30'!
prim: result dbOpen: name create: createFlag

	<primitive: 'primitiveDbOpen' module: 'BerkeleyDbPlugin'>
	self primitiveFailed! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:31'!
prim: result dbVerify: db

	<primitive: 'primitiveDbVerify' module: 'BerkeleyDbPlugin'>
	self primitiveFailed
! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:31'!
prim: result dbcClose: dbc

	<primitive: 'primitiveDbCursorClose' module: 'BerkeleyDbPlugin'>
	self primitiveFailed
! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/2/2002 20:31'!
prim: result dbcNext: dbc

	<primitive: 'primitiveDbCursorNext' module: 'BerkeleyDbPlugin'>
	self primitiveFailed
! !

!BdbDatabase methodsFor: 'primitives' stamp: 'svp 12/3/2002 15:20'!
primDbIsValid: db

	<primitive: 'primitiveDbIsValid' module: 'BerkeleyDbPlugin'>
	^false
! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 10/7/2002 14:26'!
primitive: result db: dbOop at: key
	| db keySize keyPtr value valueSize errOop errmsg rCode |
	self var: #db declareC: 'Database *db'.
	self var: #keyPtr declareC: 'void *keyPtr'.
	self var: #value declareC: 'void *value'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbAt' parameters: #(Oop Oop Oop).
	db := self dbValueOf: dbOop.

	"Validate any parameters"
	interpreterProxy success: ((interpreterProxy isIntegerObject: key) not 
		and: [interpreterProxy isBytes: key]).

	interpreterProxy failed ifFalse:
		[keySize := interpreterProxy slotSizeOf: key.
		keyPtr := interpreterProxy firstIndexableField: key].
	interpreterProxy failed ifFalse:
		["BEWARE: we assume that sqDbAt will not access the key data after it allocates 
		space for the result...to do so would be dangerous as the sqDbMalloc callback 
		to allocate space for the result can trigger GC and potentially move the key data!!  
		This might not crash the system, but may simply result in the key not being 
		found, or it finding the wrong data."

		self remapOop: result in:
			[rCode := self cCode: 'sqDbAt(db, keyPtr, keySize, &value, &valueSize, &errmsg)'.
			rCode = -1 ifTrue: [errOop := self getErrorMessage: errmsg]].
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = 0 ifTrue: [result stAt: 2 put: value cPtrAsOop].
		rCode = -1 ifTrue: [result stAt: 2 put: errOop]].

	^result
! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 10/7/2002 14:28'!
primitive: result db: dbOop at: key put: value
	| db keySize valueSize keyPtr valuePtr rCode errOop errmsg |
	self var: #db declareC: 'Database *db'.
	self var: #keyPtr declareC: 'void *keyPtr'.
	self var: #valuePtr declareC: 'void *valuePtr'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbAtPut' parameters: #(Oop Oop Oop Oop).
	db := self dbValueOf: dbOop.

	"Validate any parameters"
	interpreterProxy success: ((interpreterProxy isIntegerObject: key) not 
		and: [(interpreterProxy isIntegerObject: value) not]).
	interpreterProxy failed ifFalse:
		[interpreterProxy success: (interpreterProxy isBytes: key).
		interpreterProxy success: (interpreterProxy isBytes: value)].

	interpreterProxy failed ifFalse:
		[keySize := interpreterProxy slotSizeOf: key.
		valueSize := interpreterProxy slotSizeOf: value.
		keyPtr := interpreterProxy firstIndexableField: key.
		valuePtr := interpreterProxy firstIndexableField: value].
	interpreterProxy failed ifFalse:
		[rCode := self cCode: 'sqDbAtPut(db, keyPtr, keySize, valuePtr, valueSize, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result
! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 8/15/2002 13:54'!
primitive: result db: dbOop removeKey: key
	| db keySize keyPtr rCode errOop errmsg |
	self var: #db declareC: 'Database *db'.
	self var: #keyPtr declareC: 'void *keyPtr'.
	self var: #value declareC: 'void *value'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbRemoveKey' parameters: #(Oop Oop Oop).
	db := self dbValueOf: dbOop.

	"Validate parameters"
	interpreterProxy success: (interpreterProxy isBytes: key).

	interpreterProxy failed ifFalse:
		[keySize := interpreterProxy slotSizeOf: key.
		keyPtr := interpreterProxy firstIndexableField: key].
	interpreterProxy failed ifFalse:
		[rCode := self cCode: 'sqDbRemoveKey(db, keyPtr, keySize, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result

! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 8/15/2002 13:29'!
primitive: result dbClose: dbOop
	| db errmsg rCode errOop |
	self var: #db declareC: 'Database *db'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbClose' parameters: #(Oop Oop).
	db := self dbValueOf: dbOop.

	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbClose(db, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 8/15/2002 13:31'!
primitive: result dbCommit: dbOop
	| db rCode errOop errmsg |
	self var: #db declareC: 'Database *db'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbCommit' parameters: #(Oop Oop).
	db := self dbValueOf: dbOop.

	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbCommit(db, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 8/15/2002 14:39'!
primitive: result dbCursor: dbOop
	| db dbc dbcOop rCode errOop errmsg |
	self var: #db declareC: 'Database *db'.
	self var: #dbc declareC: 'DbCursor *dbc'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbCursor' parameters: #(Oop Oop).

	interpreterProxy failed ifFalse:
		[self remapOop: #(result dbOop) in: 
			[dbcOop := interpreterProxy 
				instantiateClass: interpreterProxy classByteArray 
				indexableSize: self dbcRecordSize]].

	interpreterProxy failed ifFalse:
		[db := self dbValueOf: dbOop.
		dbc := self dbcValueOf: dbcOop].

	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbCursor(db, dbc, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = 0 ifTrue: [result stAt: 2 put: dbcOop].
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result
! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 8/15/2002 13:37'!
primitive: result dbCursorClose: dbcOop
	| dbc errmsg rCode errOop |
	self var: #dbc declareC: 'DbCursor *dbc'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbCursorClose' parameters: #(Oop Oop).
	dbc := self dbcValueOf: dbcOop.

	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbCursorClose(dbc, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 8/15/2002 15:01'!
primitive: result dbCursorNext: dbcOop
	| dbc key keySize value valueSize keyOop valueOop errmsg rCode errOop |
	self var: #dbc declareC: 'DbCursor *dbc'.
	self var: #key declareC: 'void *key'.
	self var: #value declareC: 'void *value'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbCursorNext' parameters: #(Oop Oop).
	dbc := self dbcValueOf: dbcOop.

	interpreterProxy failed ifTrue: [self cCode: 'fprintf(stderr,"got failure at 1\n")'].
	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbCursorNext(dbc, &key, &keySize, &value, &valueSize, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = 0 ifTrue:
			[self remapOop: result in: 
				[keyOop _ interpreterProxy 
					instantiateClass: interpreterProxy classByteArray 
					indexableSize: keySize].
			self remapOop: #(result keyOop) in: 
				[valueOop _ interpreterProxy 
					instantiateClass: interpreterProxy classByteArray 
					indexableSize: valueSize].
			self cCode: 'memcpy((void*) (keyOop + 4), key, keySize)'.
			self cCode: 'memcpy((void*) (valueOop + 4), value, valueSize)'.
			result stAt: 2 put: keyOop.
			result stAt: 3 put: valueOop].
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 8/15/2002 08:22'!
primitive: result dbOpen: fileName create: createFlag
	| fileNamePtr fileNameSize dbOop db errmsg rCode errOop |
	self var: #db declareC: 'Database *db'.
	self var: #fileNamePtr declareC: 'char *fileNamePtr'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbOpen' parameters: #(Oop Oop Boolean).

	"Validate any parameters"
	interpreterProxy success: (interpreterProxy isBytes: fileName).

	interpreterProxy failed ifFalse:
		[self remapOop: fileName in:
			[dbOop _ interpreterProxy 
				instantiateClass: interpreterProxy classByteArray 
				indexableSize: self dbRecordSize].
		db := self dbValueOf: dbOop].

	fileNamePtr := interpreterProxy firstIndexableField: fileName.
	fileNameSize := interpreterProxy slotSizeOf: fileName.

	interpreterProxy failed ifFalse:
		[rCode := self cCode: 'sqDbOpen(db, fileNamePtr, fileNameSize, createFlag, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = 0 ifTrue: [result stAt: 2 put: dbOop]].
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop].
	^result! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 8/15/2002 15:21'!
primitive: result dbVerify: dbOop
	| db errmsg rCode errOop |
	self var: #db declareC: 'Database *db'.
	self var: #errmsg declareC: 'char *errmsg'.
	self primitive: 'primitiveDbVerify' parameters: #(Oop Oop).
	db := self dbValueOf: dbOop.

	interpreterProxy failed ifFalse: 
		[rCode := self cCode: 'sqDbVerify(db, &errmsg)'.
		result stAt: 1 put: rCode asSmallIntegerObj.
		rCode = -1 ifTrue: 
			[self remapOop: result in: [errOop := self getErrorMessage: errmsg].
			result stAt: 2 put: errOop]].
	^result
! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 6/4/2002 13:37'!
primitiveDbIsValid: dbOop
	| db ret |
	self var: #db declareC: 'Database *db'.
	self primitive: 'primitiveDbIsValid' parameters: #(Oop).
	db := self dbValueOf: dbOop.
	interpreterProxy failed ifFalse: [ret := self sqDbIsValid: db].
	^ret asBooleanObj
! !

!BdbDatabase methodsFor: 'error handling' stamp: 'svp 8/15/2002 15:24'!
primitiveResultError: result

	result first = 100 ifTrue: [^self error: 'memory allocation error'].
	result first = 99 ifTrue: [^self error: 'invalid db handle'].
	result first = 98 ifTrue: [^self error: 'invalid cursor handle'].
	result first = -1 ifTrue: [^self error: result second].
	^self error: 'invalid result from primitive'! !

!BdbDatabase methodsFor: 'printing' stamp: 'svp 6/5/2002 15:56'!
printOn: strm

	super printOn: strm.
	strm nextPut: $(.
	strm nextPutAll: self fileName.
	strm nextPut: $).
! !

!BdbDatabase methodsFor: 'initialization' stamp: 'svp 6/5/2002 21:11'!
refreshDbHandle

	self unregister.
	self open: self fileName create: false
! !

!BdbDatabase methodsFor: 'registry' stamp: 'svp 6/5/2002 16:44'!
register
	^self class register: self! !

!BdbDatabase class methodsFor: 'registry' stamp: 'svp 6/5/2002 16:35'!
register: anObject
	WeakArray isFinalizationSupported ifFalse:[^anObject].
	self registry add: anObject! !

!BdbDatabase class methodsFor: 'registry' stamp: 'svp 6/5/2002 16:35'!
registry
	WeakArray isFinalizationSupported ifFalse:[^nil].
	^Registry isNil
		ifTrue:[Registry := WeakRegistry new]
		ifFalse:[Registry].! !

!BdbDatabase methodsFor: 'removing' stamp: 'svp 6/4/2002 16:35'!
removeKey: key

	self removeKey: key ifAbsent: [self errorKeyNotFound]! !

!BdbDatabase methodsFor: 'removing' stamp: 'svp 8/15/2002 14:30'!
removeKey: key ifAbsent: aBlock

	| result |
	result := self prim: {nil.nil} db: self dbHandle removeKey: key.
	result first = 0 ifTrue: [^self].
	result first = 1 ifTrue: [^aBlock value].
	self primitiveResultError: result.
! !

!BerkeleyDbPlugin class methodsFor: 'translation' stamp: 'svp 5/30/2002 10:35'!
requiresCrossPlatformFiles
	"this plugin requires cross platform files in order to work"
	^true! !

!BdbDatabase methodsFor: 'enumeration' stamp: 'svp 6/5/2002 15:33'!
select: aBlock 
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!!"

	"Evaluate aBlock with each of my values as the argument. Collect into a
	new dictionary, only those associations for which aBlock evaluates to
	true."

	| newCollection |
	newCollection _ Dictionary new.
	self associationsDo: 
		[:each | 
		(aBlock value: each value) ifTrue: [newCollection add: each]].
	^newCollection! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 5/24/2002 15:13'!
shutdownModule
	"Initialise the module"
	self export: true.
	^self cCode: 'sqDbShutdown()' inSmalltalk:[true]! !

!BerkeleyDbPlugin methodsFor: 'primitives' stamp: 'svp 6/1/2002 11:27'!
sqDbMalloc: size
	"Allocate a byte array of size bytes and return a pointer to the first field.  This 
	function is provided for use by the database implementation for returning data 
	associated with a given key.  This serves two purposes, a) the database implementation
	can use this function to allocate a buffer for returned data where the size of that 
	data is not known in advance of the call, and b) the database implementation can write
	directly into the object memory, eliminating the need to copy the data into a Smalltalk
	byte array at a later time."

	| oop |
	self returnTypeC: 'void *'.
	oop := interpreterProxy instantiateClass: interpreterProxy classByteArray indexableSize: size.
	^self cCode: '(void *) (oop + 4)'

! !

!BdbDatabase methodsFor: 'maintenance' stamp: 'svp 6/5/2002 21:10'!
truncate
	"Deletes the database and creates a new one by the same name"

	self closeAndDelete.
	self open: self fileName create: true.! !

!BdbDatabase methodsFor: 'maintenance' stamp: 'svp 8/9/2002 16:54'!
unprepare

	"There is nothing to do here...we assume that we are the only open connection
	to the database.  Under that assumption, all prepares are successful."
! !

!BdbDatabase methodsFor: 'registry' stamp: 'svp 6/5/2002 16:44'!
unregister
	^self class unregister: self! !

!BdbDatabase class methodsFor: 'registry' stamp: 'svp 6/5/2002 16:35'!
unregister: anObject
	WeakArray isFinalizationSupported ifFalse:[^anObject].
	self registry remove: anObject ifAbsent:[]! !

!BdbDatabase methodsFor: 'accessing' stamp: 'svp 6/5/2002 15:23'!
values
	"WARNING: If you have a large database, this could take a long time and
	consume lots of memory!!"

	"Answer a Collection containing the receiver's values."
	| out |
	out _ WriteStream on: (Array new: 20).
	self valuesDo: [:value | out nextPut: value].
	^ out contents! !

!BdbDatabase methodsFor: 'enumeration' stamp: 'svp 6/5/2002 15:24'!
valuesDo: aBlock 
	"WARNING: If you have a large database this could take a long time!!"

	"Evaluate aBlock for each of the receiver's keys."

	self associationsDo: [:association | aBlock value: association value]! !

!BdbDatabase methodsFor: 'maintenance' stamp: 'svp 8/15/2002 15:24'!
verify

	| result |
	result := self prim: {nil.nil} dbVerify: self dbHandle.
	result first ~= 0 ifTrue: [self primitiveResultError: result]! !

Smalltalk at: #FilePackageManager ifPresent: [:p | p registerPackage: 'BerkeleyDB'].!

