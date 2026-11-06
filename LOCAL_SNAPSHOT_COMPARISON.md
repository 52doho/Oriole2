# Oriole2-ori comparison

Compared with Oriole2 commit `9430f9c` on 2026-11-06, using file contents rather
than timestamps or executable permissions. Excluded `.git`, `.DS_Store`, Xcode
user settings, checkout metadata and project-internal workspaces.

Only two source files differ; all other source, resources, Podfiles, lockfiles,
podspecs and bundled dependency files match.

| File | Change in Oriole2-ori | Integration status |
| --- | --- | --- |
| `Oriole2/Ad/OOAd.m` | Adds a hardcoded AdMob test device to interstitial requests | Pending; scope test configuration to Debug builds |
| `Oriole2/Common/OOCommon.m` | Replaces obsolete MBProgressHUD label/hide calls with 1.x APIs | Pending compilation verification |

The snapshot additionally contains `Oriole2.xcworkspace/contents.xcworkspacedata`,
`xcshareddata/IDEWorkspaceChecks.plist` and `xcshareddata/Oriole2.xcscmblueprint`.
The workspace references will be inspected before importing; local SCM metadata
is not application functionality.

The original Oriole2-ori directory remains the comparison baseline.
