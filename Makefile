INSTALL_DIR="/Library/Application Support/MonkeyWorks/Developer"
STAGING_DIR="/tmp/mw_staging"
BOOST=boost_1_36_0
CPPUNIT=cppunit-1.12.0
TIFF=tiff-3.8.2
ZLIB=zlib-1.2.3
JPEG=jpeg-6b
PNG=libpng-1.2.12
LCMS=lcms-1.15
MNG=libmng-1.0.9
DEVIL=DevIL-1.6.8

# Boost options
BJAM=./tools/jam/src/bin.macosxx86/bjam
BJAM_CONFIG="--layout=system"
BOOST_LIBS=

all: boost ILUT monkeyworks-lib cppunit

monkeyworks-lib:
	mkdir -p $(INSTALL_DIR)/lib
	mkdir -p $(INSTALL_DIR)/include
	mkdir -p $(INSTALL_DIR)/man
	mkdir -p $(INSTALL_DIR)/bin
	mkdir -p $(INSTALL_DIR)/share
	mkdir -p $(INSTALL_DIR)/../Plugins
	mkdir -p $(INSTALL_DIR)/../Configuration
	mkdir -p $(INSTALL_DIR)/../Scripting/Matlab
	mkdir -p $(INSTALL_DIR)/../Scripting/Python
	mkdir -p $(INSTALL_DIR)/../Developer/tests

staging-area:
	mkdir -p $(STAGING_DIR)
	mkdir -p $(INSTALL_DIR)/lib
	mkdir -p $(INSTALL_DIR)/include
	if test -e $(STAGING_DIR)/lib; then echo "No need to link lib"; else ln -s -f $(INSTALL_DIR)/lib $(STAGING_DIR)/lib; fi;
	if test -e $(STAGING_DIR)/include; then echo "No need to link include"; else ln -s -f $(INSTALL_DIR)/include $(STAGING_DIR)/include; fi;

boost: staging-area monkeyworks-lib
	if test -e $(STAGING_DIR)/boost-svn; \
	then echo "No need to check out new boost copy"; \
	else echo "Checking out a fresh copy"; \
	svn co http://svn.boost.org/svn/boost/tags/release/Boost_1_36_0 $(STAGING_DIR)/boost-svn; \
	fi;
	cp boost_mw.patch $(STAGING_DIR)/boost-svn/;\
	cd $(STAGING_DIR)/boost-svn/; \
	find ./ -name ".svn" -print | xargs rm -rf; \
	patch -Np6 -f < boost_mw.patch; \
	chmod u+x $(BJAM); \
	$(BJAM) $(BJAM_CONFIG) --user-config=user-config.jam.osx $(BOOST_LIBS) || echo "Boost build failed"; \
	$(BJAM) $(BJAM_CONFIG) --user-config=user-config.jam.osx --prefix=$(INSTALL_DIR) --exec-prefix=$(INSTALL_DIR) --libdir=$(INSTALL_DIR)/lib --includedir=$(INSTALL_DIR)/include $(BOOST_LIBS) install || echo "Not all Boost libraries built properly."
	rm -rf $(INSTALL_DIR)/lib/libboost_*.dylib

clean-boost:
	rm -rf $(INSTALL_DIR)/include/boost
	rm -rf $(INSTALL_DIR)/lib/libboost_*

cppunit: monkeyworks-lib
	(cd $(CPPUNIT); ./configure --prefix=$(STAGING_DIR)/cppunit; make; make install)
	rsync -av --exclude *.dylib $(STAGING_DIR)/cppunit/ $(INSTALL_DIR)/
	rm -rf $(STAGING_DIR)/cppunit

clean-cppunit:
	(cd $(CPPUNIT); ./configure --prefix=$(INSTALL_DIR); make distclean)
	rm -f ${INSTALL_DIR}/lib/libcppunit*
	rm -f ${INSTALL_DIR}/lib/pkgconfig/cppunit.pc
	rm -rf ${INSTALL_DIR}/include/cppunit
	

ILUT: z tiff jpeg mng lcms png DevIL monkeyworks-lib
	mkdir -p $(INSTALL_DIR)/lib/temp_ILUT
	mv $(INSTALL_DIR)/lib/libIL.a $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x libIL.a)
	mv $(INSTALL_DIR)/lib/libILU.a  $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x libILU.a )
	mv $(INSTALL_DIR)/lib/libILUT.a  $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x libILUT.a )
	mv $(INSTALL_DIR)/lib/libjpeg.a  $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x libjpeg.a )
	mv $(INSTALL_DIR)/lib/liblcms.a  $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x liblcms.a )
	mv $(INSTALL_DIR)/lib/libmng.a  $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x libmng.a )
	mv $(INSTALL_DIR)/lib/libpng12.a  $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x libpng12.a )
	mv $(INSTALL_DIR)/lib/libtiff.a  $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x libtiff.a )
	mv $(INSTALL_DIR)/lib/libtiffxx.a  $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x libtiffxx.a )
	mv $(INSTALL_DIR)/lib/libz.a  $(INSTALL_DIR)/lib/temp_ILUT
	(cd $(INSTALL_DIR)/lib/temp_ILUT; ar -x libz.a )

	ar -r $(INSTALL_DIR)/lib/libILUT.a $(INSTALL_DIR)/lib/temp_ILUT/*.o

	rm -f $(INSTALL_DIR)/lib/libjpeg.62.0.0.dylib 
	rm -f $(INSTALL_DIR)/lib/libjpeg.62.dylib 
	rm -f $(INSTALL_DIR)/lib/libjpeg.dylib 
	rm -f $(INSTALL_DIR)/lib/libtiff.3.dylib 
	rm -f $(INSTALL_DIR)/lib/libtiff.dylib 
	rm -f $(INSTALL_DIR)/lib/libtiffxx.3.dylib 
	rm -f $(INSTALL_DIR)/lib/libtiffxx.dylib
	rm -f $(INSTALL_DIR)/lib/libjpeg.62.0.0.dylib 
	rm -f $(INSTALL_DIR)/lib/libjpeg.62.dylib 
	rm -f $(INSTALL_DIR)/lib/libjpeg.dylib 
	rm -f $(INSTALL_DIR)/lib/libtiff.3.dylib 
	rm -f $(INSTALL_DIR)/lib/libtiff.dylib 
	rm -f $(INSTALL_DIR)/lib/libtiffxx.3.dylib 
	rm -f $(INSTALL_DIR)/lib/libtiffxx.dylib

	rm -f $(INSTALL_DIR)/lib/libIL.la
	rm -f $(INSTALL_DIR)/lib/libILU.la
	rm -f $(INSTALL_DIR)/lib/libILUT.la
	rm -f $(INSTALL_DIR)/lib/libjpeg.la
	rm -f $(INSTALL_DIR)/lib/liblcms.la
	rm -f $(INSTALL_DIR)/lib/libpng.la
	rm -f $(INSTALL_DIR)/lib/libpng12.la
	rm -f $(INSTALL_DIR)/lib/libtiff.la
	rm -f $(INSTALL_DIR)/lib/libtiffxx.la

	rm -f $(INSTALL_DIR)/lib/libpng.a
	rm -f $(INSTALL_DIR)/lib/libpng.so

	rm -rf $(INSTALL_DIR)/lib/pkgconfig
	rm -rf $(INSTALL_DIR)/lib/temp_ILUT


clean-ILUT: clean-z clean-jpeg clean-tiff clean-mng clean-lcms clean-png clean-DevIL


z: monkeyworks-lib
	(cd image_libs/$(ZLIB); ./configure --prefix=$(STAGING_DIR)/zlib; make; make install) 
	rsync -av $(STAGING_DIR)/zlib/ $(INSTALL_DIR)/
	rm -rf $(STAGING_DIR)/zlib

clean-z:
	(cd image_libs/$(ZLIB); ./configure --prefix=$(INSTALL_DIR); make distclean)
	rm -f $(INSTALL_DIR)/include/zconf.h
	rm -f $(INSTALL_DIR)/include/zlib.h
	rm -f $(INSTALL_DIR)/lib/libz.a
	rm -f $(INSTALL_DIR)/share/man/man3/zlib.3
	


png: z monkeyworks-lib
	(cd image_libs/$(PNG); ./configure --prefix=$(STAGING_DIR)/png --enable-static --enable-shared=no; make; make check; make install) 
	rsync -av $(STAGING_DIR)/png/ $(INSTALL_DIR)/
	rm -rf $(STAGING_DIR)/png

clean-png:
	(cd image_libs/$(PNG); ./configure --prefix=$(INSTALL_DIR) --enable-static --enable-shared=no; make distclean) 
	rm -f $(INSTALL_DIR)/bin/libpng12-config
	rm -f $(INSTALL_DIR)/include/libpng12/png.h
	rm -f $(INSTALL_DIR)/include/libpng12/pngconf.h
	rm -f $(INSTALL_DIR)/lib/libpng12.a
	rm -f $(INSTALL_DIR)/lib/libpng12.la
	rm -f $(INSTALL_DIR)/lib/pkgconfig/libpng12.pc
	rm -f $(INSTALL_DIR)/man/man3/libpng.3
	rm -f $(INSTALL_DIR)/man/man3/libpngpf.3
	rm -f $(INSTALL_DIR)/man/man5/png.5
	

lcms: staging-area z tiff jpeg monkeyworks-lib
	(cd image_libs/$(LCMS); ./configure --prefix=$(STAGING_DIR)/lcms --enable-static --disable-shared LDFLAGS=-L$(STAGING_DIR)/lib CPPFLAGS=-I$(STAGING_DIR)/include; make clean; make; make check; make install) 
	rsync -av $(STAGING_DIR)/lcms/ $(INSTALL_DIR)/
	rm -rf $(STAGING_DIR)/lcms

clean-lcms: staging-area
#	(cd image_libs/$(LCMS); ./configure --prefix=$(INSTALL_DIR) --enable-static --disable-shared LDFLAGS=-L$(INSTALL_DIR)/lib CPPFLAGS=-I$(INSTALL_DIR)/include; make distclean) 
	rm -f $(INSTALL_DIR)/bin/icc2ps
	rm -f $(INSTALL_DIR)/bin/icclink
	rm -f $(INSTALL_DIR)/bin/icctrans
	rm -f $(INSTALL_DIR)/bin/jpegicc
	rm -f $(INSTALL_DIR)/bin/tiffdiff
	rm -f $(INSTALL_DIR)/bin/tifficc
	rm -f $(INSTALL_DIR)/bin/wtpt
	rm -f $(INSTALL_DIR)/include/icc34.h
	rm -f $(INSTALL_DIR)/include/lcms.h
	rm -f $(INSTALL_DIR)/lib/liblcms.a
	rm -f $(INSTALL_DIR)/lib/liblcms.la
	rm -f $(INSTALL_DIR)/lib/pkgconfig/lcms.pc
	rm -f $(INSTALL_DIR)/man/man1/icc2ps.1
	rm -f $(INSTALL_DIR)/man/man1/icclink.1
	rm -f $(INSTALL_DIR)/man/man1/jpegicc.1
	rm -f $(INSTALL_DIR)/man/man1/tifficc.1
	rm -f $(INSTALL_DIR)/man/man1/wtpt.1



mng: staging-area mng-makefile jpeg lcms monkeyworks-lib
	(cd image_libs/$(MNG); make)
	cp image_libs/$(MNG)/libmng.a $(STAGING_DIR)/lib
	cp image_libs/$(MNG)/libmng.h $(STAGING_DIR)/include

clean-mng: mng-makefile
	(cd image_libs/$(MNG); make clean)
	rm -f image_libs/$(MNG)/Makefile.tmp
	rm -f image_libs/$(MNG)/Makefile2.tmp
	rm -f $(INSTALL_DIR)/lib/libmng.a
	rm -f $(INSTALL_DIR)/include/libmng.h

mng-makefile: image_libs/$(MNG)/makefiles/makefile.unix
	sed s:/cs/include/jpeg:$(STAGING_DIR)/include: image_libs/$(MNG)/makefiles/makefile.unix > image_libs/$(MNG)/Makefile.tmp
	sed s:/cs/include:$(STAGING_DIR)/include:  image_libs/$(MNG)/Makefile.tmp > image_libs/$(MNG)/Makefile2.tmp
	sed s:/ltmp/lcms-1.06/source:$(STAGING_DIR)/include: image_libs/$(MNG)/Makefile2.tmp > image_libs/$(MNG)/Makefile

DevIL: staging-area z mng tiff jpeg lcms png monkeyworks-lib
	(cd $(DEVIL); ./configure --prefix=$(STAGING_DIR) --enable-static --disable-shared LDFLAGS=-L$(STAGING_DIR)/lib CPPFLAGS=-I$(STAGING_DIR)/include; make clean; make; make install)

clean-DevIL: staging-area
	(cd $(DEVIL); ./configure --prefix=$(STAGING_DIR) --enable-static --disable-shared LDFLAGS=-L$(STAGING_DIR)/lib CPPFLAGS=-I$(STAGING_DIR)/include; make distclean)
	rm -f $(INSTALL_DIR)/include/IL/config.h
	rm -f $(INSTALL_DIR)/include/IL/devil_internal_exports.h
	rm -f $(INSTALL_DIR)/include/IL/il.h
	rm -f $(INSTALL_DIR)/include/IL/il_wrap.h
	rm -f $(INSTALL_DIR)/include/IL/ilu.h
	rm -f $(INSTALL_DIR)/include/IL/ilu_region.h
	rm -f $(INSTALL_DIR)/include/IL/ilut.h
	rm -f $(INSTALL_DIR)/lib/libIL.a
	rm -f $(INSTALL_DIR)/lib/libIL.la
	rm -f $(INSTALL_DIR)/lib/libILU.a
	rm -f $(INSTALL_DIR)/lib/libILU.la
	rm -f $(INSTALL_DIR)/lib/libILUT.a
	rm -f $(INSTALL_DIR)/lib/libILUT.la

jpeg: staging-area monkeyworks-lib
	ln -sf `which glibtool` image_libs/$(JPEG)/libtool
	mkdir -p $(STAGING_DIR)/jpeg/include
	mkdir -p $(STAGING_DIR)/jpeg/lib
	(cd image_libs/$(JPEG); ./configure --prefix=$(STAGING_DIR)/jpeg --enable-static --disable-shared; make clean; make; make install-lib) 
	rsync -av $(STAGING_DIR)/jpeg/ $(INSTALL_DIR)/

clean-jpeg:
	(cd image_libs/$(JPEG); ./configure --prefix=$(STAGING_DIR) --enable-static --disable-shared; make distclean) 
	rm -f image_libs/$(JPEG)/libtool
	rm -f $(INSTALL_DIR)/include/jconfig.h
	rm -f $(INSTALL_DIR)/include/jerror.h
	rm -f $(INSTALL_DIR)/include/jpeglib.h
	rm -f $(INSTALL_DIR)/include/jmorecfg.h
	rm -f $(INSTALL_DIR)/lib/libjpeg*


clean: clean-cppunit clean-boost clean-ILUT 

tiff: staging-area jpeg z monkeyworks-lib
	(cd image_libs/$(TIFF); ./configure -prefix=$(STAGING_DIR)/tiff --enable-static --with-zlib-include-dir=$(STAGING_DIR)/zlib/include --with-zlib-lib-dir=$(STAGING_DIR)/zlib/lib --with-jpeg-include-dir=$(STAGING_DIR)/include --with-jpeg-lib-dir=$(STAGING_DIR)/lib --with-apple-opengl-framework; make clean; make; make install) 
	rsync -av $(STAGING_DIR)/tiff/ $(INSTALL_DIR)/
	#rm -rf $(STAGING_DIR)/tiff

clean-tiff:
	(cd image_libs/$(TIFF); ./configure --prefix=$(INSTALL_DIR); make distclean) 
	rm -f $(INSTALL_DIR)/bin/bmp2tiff
	rm -f $(INSTALL_DIR)/bin/fax2ps
	rm -f $(INSTALL_DIR)/bin/fax2tiff
	rm -f $(INSTALL_DIR)/bin/gif2tiff
	rm -f $(INSTALL_DIR)/bin/pal2rgb
	rm -f $(INSTALL_DIR)/bin/ppm2tiff
	rm -f $(INSTALL_DIR)/bin/ras2tiff
	rm -f $(INSTALL_DIR)/bin/raw2tiff
	rm -f $(INSTALL_DIR)/bin/rgb2ycbcr
	rm -f $(INSTALL_DIR)/bin/thumbnail
	rm -f $(INSTALL_DIR)/bin/tiff2bw
	rm -f $(INSTALL_DIR)/bin/tiff2pdf
	rm -f $(INSTALL_DIR)/bin/tiff2ps
	rm -f $(INSTALL_DIR)/bin/tiff2rgba
	rm -f $(INSTALL_DIR)/bin/tiffcmp
	rm -f $(INSTALL_DIR)/bin/tiffcp
	rm -f $(INSTALL_DIR)/bin/tiffdither
	rm -f $(INSTALL_DIR)/bin/tiffdump
	rm -f $(INSTALL_DIR)/bin/tiffgt
	rm -f $(INSTALL_DIR)/bin/tiffinfo
	rm -f $(INSTALL_DIR)/bin/tiffmedian
	rm -f $(INSTALL_DIR)/bin/tiffset
	rm -f $(INSTALL_DIR)/bin/tiffsplit
	rm -f $(INSTALL_DIR)/include/tiff.h
	rm -f $(INSTALL_DIR)/include/tiffconf.h
	rm -f $(INSTALL_DIR)/include/tiffio.h
	rm -f $(INSTALL_DIR)/include/tiffio.hxx
	rm -f $(INSTALL_DIR)/include/tiffvers.h
	rm -f $(INSTALL_DIR)/lib/libtiff.*
	rm -f $(INSTALL_DIR)/lib/libtiffxx.*
	rm -f $(INSTALL_DIR)/man/man1/bmp2tiff.1
	rm -f $(INSTALL_DIR)/man/man1/fax2ps.1
	rm -f $(INSTALL_DIR)/man/man1/fax2tiff.1
	rm -f $(INSTALL_DIR)/man/man1/gif2tiff.1
	rm -f $(INSTALL_DIR)/man/man1/pal2rgb.1
	rm -f $(INSTALL_DIR)/man/man1/ppm2tiff.1
	rm -f $(INSTALL_DIR)/man/man1/ras2tiff.1
	rm -f $(INSTALL_DIR)/man/man1/raw2tiff.1
	rm -f $(INSTALL_DIR)/man/man1/rgb2ycbcr.1
	rm -f $(INSTALL_DIR)/man/man1/sgi2tiff.1
	rm -f $(INSTALL_DIR)/man/man1/thumbnail.1
	rm -f $(INSTALL_DIR)/man/man1/tiff2bw.1
	rm -f $(INSTALL_DIR)/man/man1/tiff2pdf.1
	rm -f $(INSTALL_DIR)/man/man1/tiff2ps.1
	rm -f $(INSTALL_DIR)/man/man1/tiff2rgba.1
	rm -f $(INSTALL_DIR)/man/man1/tiffcmp.1
	rm -f $(INSTALL_DIR)/man/man1/tiffcp.1
	rm -f $(INSTALL_DIR)/man/man1/tiffdither.1
	rm -f $(INSTALL_DIR)/man/man1/tiffdump.1
	rm -f $(INSTALL_DIR)/man/man1/tiffgt.1
	rm -f $(INSTALL_DIR)/man/man1/tiffinfo.1
	rm -f $(INSTALL_DIR)/man/man1/tiffmedian.1
	rm -f $(INSTALL_DIR)/man/man1/tiffset.1
	rm -f $(INSTALL_DIR)/man/man1/tiffsplit.1
	rm -f $(INSTALL_DIR)/man/man1/tiffsv.1
	rm -f $(INSTALL_DIR)/man/man3/libtiff.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFbuffer.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFClose.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFcodec.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFcolor.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFDataWidth.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFError.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFFlush.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFGetField.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFmemory.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFOpen.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFPrintDirectory.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFquery.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadDirectory.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadEncodedStrip.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadEncodedTile.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadRawStrip.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadRawTile.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadRGBAImage.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadRGBAStrip.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadRGBATile.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadScanline.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFReadTile.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFRGBAImage.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFSetDirectory.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFSetField.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFsize.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFstrip.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFswab.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFtile.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFWarning.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFWriteDirectory.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFWriteEncodedStrip.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFWriteEncodedTile.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFWriteRawStrip.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFWriteRawTile.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFWriteScanline.3tiff
	rm -f $(INSTALL_DIR)/man/man3/TIFFWriteTile.3tiff
	rm -rf $(INSTALL_DIR)/share/doc/tiff-3.8.2



