rm "dist/tmpimg.dmg"
rm "dist/EasyABC_1.3.7.dmg"
rm -r "dmg/EasyABC.app"
cp -r "dist/EasyABC.app" "dmg/"
hdiutil detach /Volumes/EasyABC\ 1.3.7
hdiutil create "dist/tmpimg.dmg" -volname "EasyABC 1.3.7" -fs HFS+ -srcfolder "dmg" -format UDRW
hdiutil attach "dist/tmpimg.dmg"
cp DS_Store /Volumes/EasyABC\ 1.3.7/.DS_Store
#rm -r /Volumes/EasyABC\ 1.3.7/.fseventsd
hdiutil detach /Volumes/EasyABC\ 1.3.7
hdiutil convert "dist/tmpimg.dmg" -format UDZO -o "dist/EasyABC_1.3.7.dmg"
