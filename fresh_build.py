import os
import sys
import subprocess as sp 
import re
import getopt

def usage():
    print("""Usage:
              fresh_build.py  --help
              fresh_build.py --rebuild_all
              fresh_build.py --sdk=SDK_VERSION
              """)
    return

opts, args = getopt.getopt(sys.argv[1:], "hrs:", ["help", "rebuild_all", "sdk="])

rebuild_all = False
sdk = '10.6'


for o, a in opts:
    if o in ("-h", "--help"):
        usage()
        sys.exit()
    elif o in ("-r", "--rebuild_all"):
        rebuild_all = True
    elif o in ("-s", "--sdk"):
        sdk = a
    else:
        assert False, "unhandled option: %s" % o

base_dir = os.path.abspath(os.curdir)
staging_root = "/tmp/mw_staging"
current_dir = "/tmp"

if sdk == '10.5':
    use_gcc_40 = True
    gcc_path = "/usr/bin/gcc-4.0"
    gplusplus_path = "/usr/bin/g++-4.0"
    opt_cflags = ""
    python_version = "2.5"
elif sdk == '10.6':
    use_gcc_40 = False
    gcc_path = "/usr/bin/gcc-4.2"
    gplusplus_path = "/usr/bin/g++-4.2"
    opt_cflags = "-mtune=core2 "
    python_version = "2.6"
else:
    assert False, "unknown sdk option: %s" % sdk

SDKstaging_root="/Developer/SDKs/MacOSX%s.sdk" % sdk
MACOSX_DEPLOYMENT_TARGET=sdk

cflags="-fexceptions -isysroot %s -mmacosx-version-min=%s -Dattribute_deprecated= -w" % (SDKstaging_root, MACOSX_DEPLOYMENT_TARGET)

install_root = "/Library/Application\ Support/MWorks/Developer"
if use_gcc_40:
     install_root += "/gcc40"


def grep(string,list):
    matches = []
    expr = re.compile(string)
    for text in list:
        match = expr.search(text)
        if match != None:
            matches.append(text)
    return matches

def print_banner(astring):
    separator = "==============================="    
    print(separator)
    print(astring)
    print(separator)

def system_call(command, env=None, raise_on_error=True):   
    
    if env is None:        
        print_banner("COMMAND: %s" % command)
    else:
        print_banner("COMMAND: %s (%s)" % (command, env))

    subcommands = command.split(";")

    for subcommand in subcommands:
        code = sp.call(subcommand.split(), env=env)
   
    if code != 0 and raise_on_error:
        raise Exception("A fatal error occurred")
    # TODO: add in better error checking

def change_dir(target):
    
    print_banner("CHANGING to dir: %s" % target)
    os.chdir(target)
    current_dir = target

def nuke_project(project_name):
    print_banner("Completely removing project %s" % project_name)
    system_call("rm -rf %s/%s" % (staging_root, project_name))

def clone(project_name):
    print_banner("CLONING %s" % project_name)
    change_dir(staging_root)
    
    if(project_name in os.listdir(staging_root) and not reclone_all):
        print("Nothing to do")
        return
    else:
        nuke_project(project_name)

    system_call("git clone %s/%s.git" % (repo, project_name))
    change_dir("%s/%s" % (staging_root, project_name))
    system_call("git submodule init; git submodule update")

def checkout(project_name, branch):
    change_dir("%s/%s" % (staging_root, project_name))
    system_call("git checkout %s" % branch)
    system_call("git submodule init; git submodule update")

def cmake_build(project_name):
    change_dir("%s/%s" % (staging_root, project_name))
    system_call("cmake .")
    system_call("make; make install")

def gnu_build(project_name, configure_options="", environment_variables={},  **kwargs):
    
    if "lame_config" in kwargs:
        lame_config = kwargs["lame_config"]
    else:
        lame_config = False
        
    if "make_calls" in kwargs:
        make_calls = kwargs["make_calls"]
    else:
        make_calls = " make clean; make; make install; make clean "
    
    change_dir("%s/%s" % (staging_root, project_name))
    dir_contents = os.listdir(os.curdir)
    if "configure" not in dir_contents:
        if "autogen.sh" in dir_contents:
            system_call("./autogen.sh")

    if not lame_config:
        environment = str(" ").join(environment_variables)
        os.system("./configure %s %s; %s" % (configure_options, environment, make_calls))
    else:
        env_dict = {}
        for e in environment_variables:
            index = e.find("=")  # find first =
            var = e[0:index]
            val = e[index+1:]
            var = (var.split(" "))[0]
            val = val.strip(" \"")
            env_dict[var] = val
        system_call("./configure %s; %s" % (configure_options, make_calls), env_dict)


def lipo(project_name, search_string, **kwargs):

    if "stashed_intermediates" in kwargs:
        stashed_intermediates = kwargs["stashed_intermediates"]
    else:
        stashed_intermediates = False
    
    if stashed_intermediates:
        i386_dir = "%s/%s/i386/stashed_lib" % (staging_root, project_name)
        x86_64_dir = "%s/%s/x86_64/stashed_lib" % (staging_root, project_name)
    else:    
        i386_dir = "%s/%s/i386/lib" % (staging_root, project_name)
        x86_64_dir = "%s/%s/x86_64/lib" % (staging_root, project_name)
    target_dir = "%s/lib" % staging_root
    
    system_call("mkdir -p %s" % target_dir)
    
    files = os.listdir(i386_dir)
    matching_files = grep(search_string, files)
    
    for f in matching_files:
        system_call("lipo -create -arch i386 %s/%s -arch x86_64 %s/%s -o %s/%s" % (i386_dir, f, x86_64_dir, f, target_dir, f))

def lipo_gnu_build(project_name, search_string, configure_options="", **kwargs):
    
    if "stash_intermediates" in kwargs:
        stash_intermediates = kwargs["stash_intermediates"]
    else:
        stash_intermediates = False
        
    i386_environment = ["CC=%s" % gcc_path, "CXXFLAGS=\"-arch i386 %s %s\"" % (cflags, opt_cflags), "CFLAGS=\"-arch i386 %s %s\"" % (cflags, opt_cflags),  "LDFLAGS=\"-arch i386 %s\"" % (cflags)]
    x86_64_environment = ["CC=%s" % gcc_path, "CXXFLAGS=\"-arch x86_64 %s %s\"" % (cflags, opt_cflags), "CFLAGS=\"-arch x86_64 %s %s\"" % (cflags, opt_cflags), "LDFLAGS=\"-arch x86_64 %s\"" % (cflags)]

    if 'environment_variables' in kwargs:
        extra_environment = kwargs.pop('environment_variables')
        i386_environment.extend(extra_environment)
        x86_64_environment.extend(extra_environment)
    
    i386_target = "%s/%s/i386" % (staging_root, project_name)
    x86_64_target = "%s/%s/x86_64" % (staging_root, project_name)
    system_call("mkdir -p %s/lib" % i386_target)
    system_call("mkdir -p %s/include" % i386_target)
    system_call("mkdir -p %s/bin" % i386_target)
    
    system_call("mkdir -p %s/lib" % x86_64_target)
    system_call("mkdir -p %s/include" % x86_64_target)
    system_call("mkdir -p %s/bin" % x86_64_target)

    print_banner("Building i386 version")
    gnu_build(project_name, configure_options + " --prefix=%s " % (i386_target), i386_environment, **kwargs)
    
    if stash_intermediates:
        system_call("mkdir -p %s/stashed_lib" % i386_target)
        os.system("cp -r %s/lib/* %s/stashed_lib/" % (i386_target, i386_target))
 
    print_banner("Building x86_64 version")
    gnu_build(project_name, configure_options + " --prefix=%s" % (x86_64_target), x86_64_environment, **kwargs)

    if stash_intermediates:
        system_call("mkdir -p %s/stashed_lib" % x86_64_target)
        os.system("cp -r %s/lib/* %s/stashed_lib/" % (x86_64_target, x86_64_target))

    
    lipo(project_name, search_string, stashed_intermediates=stash_intermediates)
    
    system_call("mkdir -p %s/include" % staging_root)
    os.system("cp -r %s/%s/i386/include/* %s/include" % (staging_root, project_name, staging_root))

def copy_project(copy_from, copy_to):
    #system_call("rsync -av %s %s" % (from to))
    system_call("cp -r %s/%s %s/%s" % (base_dir, copy_from, staging_root, copy_to))

def apply_patch(project_name, patch_name):
    change_dir("%s/%s" % (staging_root, project_name))
    os.system("patch -p1 < %s" % patch_name )

def build_boost(project_name, python_version):
    change_dir("%s/%s" % (staging_root, project_name))
    
    system_call("mkdir -p %s/include" % staging_root)
    system_call("mkdir -p %s/lib" % staging_root)
    
    system_call("rm -f CMakeCache.txt")
    
    os.system("cmake -DPYTHON_EXECUTABLE:PATH=/usr/bin/python%s -DPYTHON_INCLUDE_PATH:PATH=/System/Library/Frameworks/Python.framework/Versions/%s/Headers -DPYTHON_LIBRARY:PATH=\"-F /System/Library/Frameworks -framework Python\" -DCMAKE_INSTALL_PREFIX:PATH=%s -DBUILD_SHARED:BOOL=OFF -DBUILD_STATIC:BOOL=ON -DBUILD_MULTI_THREADED:BOOL=ON -DBUILD_DEBUG:BOOL=OFF -DBUILD_TESTING:BOOL=OFF -DCMAKE_C_COMPILER:PATH=%s -DCMAKE_CXX_COMPILER:PATH=%s -DCMAKE_OSX_ARCHITECTURES:STRING=\"i386;x86_64\" -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=\"%s\" -DCMAKE_OSX_SYSROOT:PATH=/Developer/SDKs/MacOSX%s.sdk -DBUILD_BCP:BOOL=OFF  -DBUILD_INSPECT:BOOL=OFF -DBUILD_TESTING:BOOL=OFF -DBUILD_REGRESSION_TESTS:BOOL=OFF  ." % (python_version, python_version, staging_root, gcc_path, gplusplus_path, sdk, sdk))

    system_call("make -k", None, False)
    
    target_dir = "%s/lib" % (staging_root)
    
    all_libs = os.listdir("%s/%s/lib" % (staging_root, project_name))
    
    for lib in all_libs:
        if(lib.find("libboost") == 0):
            stem = (lib.split("-mt."))[0]
            system_call("mv %s/%s/lib/%s %s/lib/%s-mw.a" % (staging_root, project_name, lib, staging_root, stem))

    #install the headers
    system_call("cp -r %s/%s/boost %s/include/" % (staging_root, project_name, staging_root))

def build_libtiff():
    # Why does libtiff's build infrastructure suck so hard?
    
    libtiff_configure_flags = "--prefix=%s --enable-static --disable-shared --disable-dependency-tracking --disable-cxx  --with-apple-opengl-framework" % (staging_root)
    combined_environment = ["CC=%s" % gcc_path, "CFLAGS=\"-arch i386 -arch x86_64 %s %s\"" % (cflags, opt_cflags), "LDFLAGS=\"-arch i386 -arch x86_64 %s\"" % (cflags)]

    gnu_build("tiff", libtiff_configure_flags, combined_environment, lame_config=False, make_calls="make; make install")
    

staging_root = "/tmp/mw_staging"
system_call("mkdir -p %s" % staging_root)


nuke_project("boost")
copy_project("boost_1_40_0", "boost")

build_boost("boost", python_version)

nuke_project("png")
copy_project("libpng-1.2.12", "png")
lipo_gnu_build("png", "\.a", "--enable-static --disable-shared", lame_config=True)

nuke_project("jpeg")
copy_project("jpeg-6b", "jpeg")
system_call("ln -s /usr/bin/glibtool %s/jpeg/libtool" % staging_root)
lipo_gnu_build("jpeg", "\.a", "--enable-static --disable-shared", lame_config=True, make_calls="make clean; make; make install-lib")

nuke_project("lcms")
copy_project("lcms-1.15", "lcms")
lipo_gnu_build("lcms", "\.a", "--enable-static --disable-shared", lame_config=True)

nuke_project("mng")
copy_project("libmng-1.0.10", "mng")
lipo_gnu_build("mng", "\.a", "--enable-static --disable-shared --with-jpeg=%s/jpeg --with-lcms=%s --with-jpeg=%s" % (staging_root, staging_root, staging_root), lame_config=True)

nuke_project("tiff")
copy_project("tiff-3.8.2", "tiff")
build_libtiff()

nuke_project("devil")
copy_project("DevIL-1.6.8", "devil")
lipo_gnu_build("devil", "\.a", "--enable-static --disable-shared --enable-opengl --disable-directx8 --disable-directx9 --disable-win32 --disable-sdl --disable-allegro --with-tiffdir=%s --with-pngdir=%s --with-mngdir=%s --with-lcmsdir=%s --with-jpegdir=%s" % (staging_root, staging_root, staging_root, staging_root, staging_root), lame_config=True, environment_variables=['CPATH=%s/include' % staging_root])

nuke_project("cppunit")
copy_project("cppunit-1.12.0", "cppunit")
lipo_gnu_build("cppunit", "\.a", "--enable-static=yes --enable-shared=no", lame_config=True)


os.system("mkdir -p %s/lib" % install_root)
os.system("mkdir -p %s/include" % install_root)
os.system("cp -R %s/lib/* %s/lib/" % (staging_root, install_root))
os.system("cp -R %s/include/* %s/include/" % (staging_root, install_root))
