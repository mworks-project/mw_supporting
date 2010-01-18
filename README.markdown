# Building #
Simply run "python fresh_build.py" to build all supporting libraries. Intermediate results will be stored in:
	/tmp/mw_staging
If you wish to ensure a clean full rebuild (_not_ usually necessary), rm -rf this tmp directory.

For the Mac version, all libraries are targeted to build as *static* libraries, and to install in:

	/Library/Application Support/MonkeyWorks/Developer/{include|lib}
	or
	/Library/Application Support/MonkeyWorks/Developer/gcc40/{include|lib}
	
depending on settings inside the fresh_build script.  The gcc40 subdirectory is placed there to help ease backward compatibility with OS X 10.5.  All libraries are built as intel-only "fat" libraries (i386 + x86_64).

Since these libraries are statically "baked-in" to MW, there is no need for end users to install them.  They are only required for developers.


# Forks of Supporting Libraries for MW #

This repository contains forked versions of several libraries required to build MW.  

### Issues with "vanilla" library versions ###

#### Boost ####

MW extensively uses Objective C++, a hybrid dialect that understands both C++ and Objective C syntax and semantics.  Unfortunately, the creators of boost never intended boost to compile under ObjC++, and they used the name "id" as a variable name (completely kosher in C++, but a keyword in ObjC).  Our forked version simply changes "id" to something else, everywhere it occurs.

Since boost is large and an incredibly stable project, we're currently including it as a submodule.  Be sure to type:

	git submodule init
	git submodule update

This will clone / update the external patched boost library.  Longer term, we may return to a check-out-and-patch strategy for this library, checking out boost from the central boost repositories, and modifying it locally.


#### DevIL ####

We use a completely unmodified version of DevIL.  However, since we've had problems with breakage across versions, and because DevIL is nowhere as "standard" as boost, we chose to host it here.

#### Image Librarys (libtiff, libjpeg, etc. etc.) ####

These libraries are extremely standard, and we may eventually transition to a check-out-and-build strategy; however, because the libraries are small (and because they were already in the repository when we transitioned to git), we currently include copies of the appropriate versions in the repository.

