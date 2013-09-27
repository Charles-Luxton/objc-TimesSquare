rm -R ./build/universal
mkdir ./build/
mkdir ./build/universal
xcodebuild -project TimesSquare.xcodeproj -target TimesSquare -sdk iphonesimulator -arch i386 -configuration Release clean build
cp ./build/Release-iphonesimulator/libTimesSquare.a ./build/universal/libTimesSquare-i386.a
xcodebuild -project TimesSquare.xcodeproj -target TimesSquare -sdk iphoneos -arch armv7 -configuration Release clean build
cp ./build/Release-iphoneos/libTimesSquare.a ./build/universal/libTimesSquare-armv7.a
xcodebuild -project TimesSquare.xcodeproj -target TimesSquare -sdk iphoneos -arch armv7s -configuration Release clean build
cp ./build/Release-iphoneos/libTimesSquare.a ./build/universal/libTimesSquare-armv7s.a
cd ./build/universal
lipo -create -output libTimesSquareUniversal.a libTimesSquare-armv7.a libTimesSquare-armv7s.a libTimesSquare-i386.a
cd ../../