maintenance
closeAndDelete

	"WARNING: this method will close and delete the database from disk!!!"

	self close.
	FileDirectory deleteFilePath: self fileName