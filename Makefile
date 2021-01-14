all: lib/libGRMustache7.xcframework

lib/libGRMustache7.xcframework: build/archives/GRMustache7-iphoneos.xcarchive/Products/libGRMustache7-iOS.a \
								build/archives/GRMustache7-iphonesimulator.xcarchive/Products/libGRMustache7-iOS.a \
								build/archives/GRMustache7-maccatalyst.xcarchive/Products/libGRMustache7-iOS.a
	mkdir -p lib
	xcodebuild -create-xcframework \
	  -library "build/archives/GRMustache7-iphonesimulator.xcarchive/Products/libGRMustache7-iOS.a" \
	  -library "build/archives/GRMustache7-iphoneos.xcarchive/Products/libGRMustache7-iOS.a" \
	  -library "build/archives/GRMustache7-maccatalyst.xcarchive/Products/libGRMustache7-iOS.a" \
	  -output "lib/libGRMustache7.xcframework"


lib/libGRMustache7-macOS.a: build/macOS/Release/libGRMustache7-macOS.a
	mkdir -p lib
	cp build/macOS/Release/libGRMustache7-macOS.a lib/libGRMustache7-macOS.a

build/archives/GRMustache7-iphoneos.xcarchive/Products/libGRMustache7-iOS.a:
	xcodebuild archive -project src/GRMustache.xcodeproj \
	           -scheme GRMustache7-iOS \
	           -configuration Release \
			   -destination 'generic/platform=iOS' \
			   -archivePath 'build/archives/GRMustache7-iphoneos' \
	           SYMROOT=../build/GRMustache7-iOS SKIP_INSTALL=NO INSTALL_PATH='/'

build/archives/GRMustache7-maccatalyst.xcarchive/Products/libGRMustache7-iOS.a:
	xcodebuild archive -project src/GRMustache.xcodeproj \
	           -scheme GRMustache7-iOS \
	           -configuration Release \
			   -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' \
			   -archivePath 'build/archives/GRMustache7-maccatalyst' \
	           SYMROOT=../build/GRMustache7-maccatalyst SKIP_INSTALL=NO INSTALL_PATH='/'

build/archives/GRMustache7-iphonesimulator.xcarchive/Products/libGRMustache7-iOS.a:
	xcodebuild archive -project src/GRMustache.xcodeproj \
	           -scheme GRMustache7-iOS \
	           -configuration Release \
			   -destination 'generic/platform=iOS Simulator' \
			   -archivePath 'build/archives/GRMustache7-iphonesimulator' \
	           SYMROOT=../build/GRMustache7-iphonesimulator SKIP_INSTALL=NO INSTALL_PATH='/'
                                                                                                                                    
build/macOS/Release/libGRMustache7-macOS.a:
	xcodebuild archive -project src/GRMustache.xcodeproj \
	           -scheme GRMustache7-MacOS \
	           -configuration Release \
			   -destination 'generic/platform=macOS' \
			   -archivePath 'build/archives/GRMustache7-macos' \
	           SYMROOT=../build/macOS SKIP_INSTALL=NO INSTALL_PATH=''

include/GRMustache.h: build/macOS/Release/libGRMustache7-macOS.a
	cp -R build/macOS/Release/include/GRMustache include

Reference: include/GRMustache.h
	# Appledoc does not parse availability macros: create a temporary directory
	# with "cleaned" GRMustache headers.
	rm -Rf /tmp/GRMustache_include
	cp -Rf include /tmp/GRMustache_include
	for f in /tmp/GRMustache_include/*; do \
	  cat $${f} | sed "s/AVAILABLE_[A-Za-z0-9_]*//g" > $${f}.tmp; \
	  mv -f $${f}.tmp $${f}; \
	done
	# Generate documentation
	mkdir Reference
	appledoc --output Reference AppledocSettings.plist /tmp/GRMustache_include || true
	# Cleanup
	rm -Rf /tmp/GRMustache_include

clean:
	rm -rf build
	rm -rf include
	rm -rf lib
	rm -rf Reference

