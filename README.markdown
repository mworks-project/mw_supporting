# Forks of Supporting Libraries for MW #

This repository contains forked versions of several libraries required to build MW.  

### Issues with "vanilla" library versions ###

#### Boost ####

MW extensively uses Objective C++, a hybrid dialect that understands both C++ and Objective C syntax and semantics.  Unfortunately, the creators of boost never intended boost to compile under ObjC++, and they used the name "id" as a variable name (completely kosher in C++, but a keyword in ObjC).  Our forked version simply changes "id" to something else, everywhere it occurs.

Since boost is large and an incredibly stable project, we've adopted a "check-out-and-patch" strategy.  That is, rather than store the fork in GitHub, we have a Makefile that checks it out and patches the offending variable names.

#### DevIL ####

We use a completely unmodified version of DevIL.  However, since we've had problems with breakage across versions, and because DevIL is nowhere as "standard" as boost, we chose to host it here.


### Building ###
Simply run "make all" to build all supporting libraries. Intermediate results will be stored in:
	/tmp/mw_staging
If you wish to ensure a clean full rebuild (_not_ usually necessary), rm -rf this directory.

For the Mac version, all libraries are targeted to build as *static* libraries, and to install in:
	/Library/Application Support/MonkeyWorks/Developer/{include|lib}
Since these libraries are statically "baked-in" to MW, there is no need for end users to install them.  They are only required for developers.