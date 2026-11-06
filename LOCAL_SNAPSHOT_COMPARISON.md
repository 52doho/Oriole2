# Oriole2-ori comparison

Compared with Oriole2 commit `9430f9c` on 2026-11-06, using file contents rather
than timestamps or executable permissions. Excluded `.git`, `.DS_Store`, Xcode
user settings, checkout metadata and project-internal workspaces.

Only two source files differ; all other source, resources, Podfiles, lockfiles,
podspecs and bundled dependency files match.

| File | Change in Oriole2-ori | Integration status |
| --- | --- | --- |
| `Oriole2/Ad/OOAd.m` | Adds a hardcoded AdMob test device to interstitial requests | Imported under `DEBUG`; verified against BoothCool's installed GoogleMobileAds headers (deprecated API warning only). Release requests keep their existing configuration |
| `Oriole2/Common/OOCommon.m` | Replaces obsolete MBProgressHUD label/hide calls with 1.x APIs | Imported; complete BoothCool Debug simulator and arm64 Release builds pass with Xcode 14.2 |

The snapshot additionally contains `Oriole2.xcworkspace/contents.xcworkspacedata`,
`xcshareddata/IDEWorkspaceChecks.plist` and `xcshareddata/Oriole2.xcscmblueprint`.
The workspace contents were imported and verified with `xcodebuild -list`.
Both references resolve to the existing app/library and Pods projects. The
`.gitignore` allows only this shared workspace definition. The local IDE check
marker and SCM blueprint are deliberately omitted as machine-specific metadata.

The original Oriole2-ori directory remains the comparison baseline.

Subsequent crash repairs in Oriole2 add Photos/ImageIO weak framework linkage
and replace AssetsLibrary execution on iOS 9+. Fully authorized saves retain the
application album; Limited authorization saves directly to the camera roll.
Both branches were exercised in BoothCool on the iOS 16.2 simulator. These repairs
are new changes beyond the original snapshot, committed separately from imports.
