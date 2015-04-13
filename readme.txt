Building the BerkeleyDBPlugin:

The first thing you need is to create two directories in your build environment.  These should be:

	.../Cross/plugins/BerkeleyDbPlugin/
	.../<platform>/plugins/BerkeleyDbPlugin/

You should replace "<platform>" with the name of the platform on which you are compiling (i.e. win32, unix, etc).

The files sqBerkeleyDatabase.c and BerkeleyDbPlugin.h should be placed in the ...Cross/plugins/BerkeleyDbPlugin directory of your build environment.  

For Unix builds, the file Makefile.inc can be used to tell the make files to link the plugin with "libdb" or any other version of the Berkeley DB library.  This file should be located in .../unix/plugins/BerkeleyDbPlugin/

When building the plugin, you should also add a symbolic link from .../Cross/plugins/BerkeleyDbPlugin/sqdb.h to the Berekely DB header file (db.h) of your choice (this should match the version of the library you are linking against).  You can also simply copy db.h to .../Cross/plugins/BerkeleyDbPlugin/sqdb.h.

For the convenience of Windows users, the compiled DLLs are provided in this archive.  They should be placed in a directory where they can be located (i.e. the directory where Squeak.exe is located).  If you are building on Windows, you will also need to modify the make files in order to link to the Berkeley DB DLL.  These changes are beyond the scope of this document.