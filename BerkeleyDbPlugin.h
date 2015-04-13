/* Header file for database plugin */

typedef struct {
	int		sessionID;
	void		*privateDbPtr;
} Database, *DatabasePtr;

typedef struct {
	int		sessionID;
	void		*privateDbcPtr;
} DbCursor, *DbCursorPtr;

int sqDbInit(void *(*sq_malloc)(size_t size) );
int sqDbShutdown(void);
int sqDbIsValid(Database*);
int sqDbOpen(Database*,char*,int,int,char**);
int sqDbClose(Database*,char**);
int sqDbCommit(Database*,char**);
int sqDbVerify(Database*,char**);
int sqDbAt(Database*,void*,int,void**,int*,char**);
int sqDbAtPut(Database*,void*,int,void*,int,char**);
int sqDbRemoveKey(Database*,void*,int,char**);
int sqDbCursor(Database*,DbCursor*,char**);
int sqDbCursorNext(DbCursor*,void**,int*,void**,int*,char**);
int sqDbCursorClose(DbCursor*,char**);
