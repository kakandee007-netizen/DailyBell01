# iphone_upload_helper

You only need this folder **if GitHub (or the iOS Files app) refuses to upload
`Assets.xcassets` properly** — for example if it treats `.xcassets` or
`.appiconset` as a single package/file instead of a folder.

It contains loose copies of every icon PNG plus the JSON metadata, so you can
rebuild the asset catalog by hand on the GitHub website.

## What's here
- `AppIcon.appiconset/` — all 9 icon PNGs + `Contents.json`
- `Assets.xcassets_Contents.json` — the top-level catalog metadata

## How to rebuild `Assets.xcassets` on the GitHub website (iPhone Safari)

GitHub lets you create folders by typing a path with `/` in the filename box.

1. In your repo, tap **Add file → Create new file**.
2. In the name box, type:
   `Assets.xcassets/Contents.json`
   (typing the `/` creates the folder). Paste the contents of
   `Assets.xcassets_Contents.json`, then **Commit**.
3. Tap **Add file → Create new file** again. In the name box, type:
   `Assets.xcassets/AppIcon.appiconset/Contents.json`
   Paste the contents of `AppIcon.appiconset/Contents.json`, then **Commit**.
4. Open the `Assets.xcassets/AppIcon.appiconset` folder on GitHub, tap
   **Add file → Upload files**, and upload all 9 PNGs from
   `AppIcon.appiconset/` in this helper folder.

That recreates the exact structure the build expects:

```
Assets.xcassets/
  Contents.json
  AppIcon.appiconset/
    Contents.json
    AppIcon-20@2x.png ... AppIcon-1024.png
```

Once that structure exists in the repo, the GitHub Actions build will pick up
the app icon automatically (it reads `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon`
from `project.yml`).
