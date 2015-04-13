#include <sys/types.h>
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#define __time_t

#include "BerkeleyDbPlugin.h"

//Note: the following header file should just be the normal
//BerkelyDB header file (db.h)...it is included as sqdb.h
//to provide an opportunity to link that file name to a specific
//version of db.h (for systems with multiple version of BerkeleyDB
//installed).  You can also just copy db.h to sqdb.h to some location
//where it will be found by the pre-processor.
 
#include "sqdb.h"

// Well known return codes
//   100 indicates a malloc failure
//    99 indicates invalid Database handle  
//    98 indicates invalid DbCursor handle

#if DB_VERSION_MAJOR > 3
 #define setmalloc(X) dbp->set_alloc(dbp,X,realloc,free)
#else
 #define setmalloc(X) dbp->set_malloc(dbp,X)
#endif

#define MALLOC(X,TYPE,SIZE) \
    X = TYPE malloc(SIZE); if(!X) return 100

#define DBCALL(X) do {                   \
    returnCode = X;                      \
    if(returnCode != 0) {                \
      *errmsg = db_strerror(returnCode); \
      return -1;                         \
    }                                    \
  } while(0)

#define GETDBP(dbp,db)                   \
  if(!((db != 0) &&                      \
     (thisDbSession != 0) &&             \
     (db->privateDbPtr != 0) &&          \
     (db->sessionID == thisDbSession)))  \
       return 99;                        \
  dbp = (DB *) db->privateDbPtr

#define GETDBCP(dbcp,dbc)                \
  if(!((dbc != 0) &&                     \
     (thisDbSession != 0) &&             \
     (dbc->privateDbcPtr != 0) &&        \
     (dbc->sessionID == thisDbSession))) \
       return 98;                        \
  dbcp = (DBC *) dbc->privateDbcPtr

static int thisDbSession = 0;
static void* (*sq_malloc)(size_t size);
static int returnCode;

//****** Plugin Initialization/Shutdown ******
int sqDbInit(void *(*squeak_malloc_function)(size_t size)) 
{
  int major, minor;
  char *version;

  if (0 != thisDbSession) return 1; /* Already initialized */
  sq_malloc = squeak_malloc_function;
  thisDbSession = clock() + time(0);
  if (0 == thisDbSession) thisDbSession = 1;
  db_version(&major, &minor, NULL);

  // The following check ensures that the version of the db.h 
  // header file that we were compiled against and the version 
  // of the libdb that we are bound with are in agreement 
  if((major != DB_VERSION_MAJOR) || (minor != DB_VERSION_MINOR)) {
    fprintf(stderr,"Error: BerkeleyDB version mismatch\n");
    fprintf(stderr,"       Header file expected %d.%d but got %d.%d\n", 
            DB_VERSION_MAJOR, DB_VERSION_MINOR, major, minor); 
    return 0;
  }
  return 1;
}

int sqDbShutdown() 
{
  return 0;
}

//****** Database methods ******
int sqDbIsValid(Database *db) 
{
  return 
    (db != 0) && 
    (thisDbSession != 0) && 
    (db->privateDbPtr != 0) && 
    (db->sessionID == thisDbSession);
}

int sqDbOpen(Database *db, char *fileNamePtr, int fileNameSize, int createFlag, char **errmsg)
{
  DB *dbp;
  char *fname;
  u_int32_t flags;

  // Create the DB pointer
  DBCALL(db_create(&dbp,NULL,0));

  // Setup our Squeak database structure
  db->sessionID = thisDbSession;
  db->privateDbPtr = (void *) dbp; 

  // Set the malloc function
  DBCALL(setmalloc(sq_malloc));

  // Copy the file name out of the Squeak String
  MALLOC(fname, (char*), fileNameSize + 1);
  if(!fname) return 1;
  memset((void *) (fname + fileNameSize), 0, 1);
  memcpy((void *) fname, fileNamePtr, fileNameSize);

  // Set the flags for the call to db->open
  if(createFlag) {
    flags = DB_CREATE;
  } else {
    flags = 0;
  }

  // Make the call to db->open
#if (DB_VERSION_MAJOR > 3) && (DB_VERSION_MINOR > 0)
  DBCALL(dbp->open(dbp,NULL,fname,NULL,DB_BTREE,flags,0664); free(fname));
#else
  DBCALL(dbp->open(dbp,fname,NULL,DB_BTREE,flags,0664); free(fname));
#endif
  return 0;
}

int sqDbClose(Database *db, char **errmsg)
{
  DB *dbp;
  
  GETDBP(dbp,db);
  db->sessionID = 0; /* mark this db struct invalid */
  db->privateDbPtr = NULL;
  DBCALL(dbp->close(dbp,0));
  return 0;
}

int sqDbCommit(Database *db, char **errmsg)
{
  DB *dbp;

  GETDBP(dbp,db);
  DBCALL(dbp->sync(dbp, 0));
  return 0;
}

int sqDbVerify(Database *db, char **errmsg)
{
  DB *dbp;

  GETDBP(dbp,db);
  DBCALL(dbp->verify(dbp,NULL,NULL,NULL,0));
  return 0;
}

int sqDbAt(Database *db, void *key, int keySize, void **value, int *valueSize, char **errmsg)
{
  DBT k, v;
  DB *dbp;
  int ret;

  GETDBP(dbp,db);
  memset(&k, 0, sizeof(k));
  memset(&v, 0, sizeof(v));

  k.data = key;
  k.size = keySize;
  v.flags = DB_DBT_MALLOC;

  ret = dbp->get(dbp, NULL, &k, &v, 0);
  if(ret != 0) {
    *value = NULL;
    *valueSize = 0;
  }
  if(ret == DB_NOTFOUND) return 1;
  DBCALL(ret);
  *value = v.data;
  *valueSize = v.size;
  return 0;
}

int sqDbAtPut(Database *db, void *key, int keySize, void *value, int valueSize, char **errmsg)
{
  DBT k, v;
  DB *dbp;
  int ret;

  GETDBP(dbp,db);
  memset(&k, 0, sizeof(k));
  memset(&v, 0, sizeof(v));

  k.data = key;
  k.size = keySize;
  v.data = value;
  v.size = valueSize;

  DBCALL(dbp->put(dbp, NULL, &k, &v, 0));
  return 0;
}

int sqDbRemoveKey(Database *db, void *key, int keySize, char **errmsg)
{
  DBT k;
  DB *dbp;
  int ret;

  GETDBP(dbp,db);
  memset(&k, 0, sizeof(k));
  k.data = key;
  k.size = keySize;
  ret = dbp->del(dbp, NULL, &k, 0);
  if(ret == DB_NOTFOUND) return 1;
  DBCALL(ret);
  return 0;
}

//****** Database Cursor methods ******
int sqDbCursor(Database *db, DbCursor *dbc, char **errmsg)
{
  DB *dbp;
  DBC *dbcp;

  GETDBP(dbp,db);
  DBCALL(dbp->cursor(dbp, NULL, &dbcp, 0));
  dbc->sessionID = thisDbSession;
  dbc->privateDbcPtr = (void *) dbcp;
  return 0;
}

int sqDbCursorNext(DbCursor *dbc, void **key, int *keySize, void **value, int *valueSize,char **errmsg)
{
  DBC *dbcp;
  DBT k, v;
  int ret;

  GETDBCP(dbcp,dbc);
  memset(&k, 0, sizeof(k));
  memset(&v, 0, sizeof(v));
  ret = dbcp->c_get(dbcp, &k, &v, DB_NEXT);
  if(ret == DB_NOTFOUND) {
    dbc->sessionID = 0;
    dbc->privateDbcPtr = NULL;
    *keySize = 0;
    return 1;
  }
  DBCALL(ret);
  *key = k.data;
  *keySize = k.size;
  *value = v.data;
  *valueSize = v.size;
  return 0;
}

int sqDbCursorClose(DbCursor *dbc, char **errmsg)
{
  DBC *dbcp;

  GETDBCP(dbcp,dbc);
  DBCALL(dbcp->c_close(dbcp));
  return 0;
}

