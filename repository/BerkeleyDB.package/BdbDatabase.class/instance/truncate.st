maintenance
truncate
	"Deletes the database and creates a new one by the same name"

	self closeAndDelete.
	self open: self fileName create: true.