rm "dist/EasyABC_1.4.0.dmg"
hdiutil create "dist/EasyABC_1.4.0.dmg" -volname "EasyABC 1.4.0" -fs HFS+ -srcfolder "dist/EasyABC.app"
