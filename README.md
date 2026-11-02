# Photo Portfolio

A static photography portfolio with a repeatable build and deployment workflow.

## Project layout

- `index.html` is both the editable source page and the GitHub Pages entry point.
- `Croatia Best of Best/` contains local, full-resolution source photographs. It is excluded from Git.
- `scripts/Build-Site.ps1` creates optimized deployable photographs.
- `site/images/` contains the optimized images committed to Git and used by the site.

## Build locally

From PowerShell in the project directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Build-Site.ps1"
```

Optional quality controls:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Build-Site.ps1" -MaxDimension 2400 -JpegQuality 82
```

Open `index.html` for a quick file preview. For a more accurate preview, serve the project directory with a local HTTP server.

Run the build again whenever source photographs change. HTML-only edits do not require a build.

## First deployment: GitHub Pages

1. Create a Git repository in this project directory.
2. Commit the project and publish it to a new public GitHub repository.
3. In the repository's **Settings → Pages**, set the source to **Deploy from a branch**.
4. Select the `main` branch and `/ (root)` directory.
5. GitHub publishes the root `index.html` at the Pages URL.

After setup, the normal release loop is:

1. Edit the source page or photographs.
2. If photographs changed, run the image build command above.
3. Review `index.html` locally.
4. Commit and push.
5. GitHub Pages automatically publishes the pushed commit.

## Why the source photos are not committed

The original photographs are roughly 22–27 MB each and are unsuitable for routine mobile delivery or a lightweight Git repository. The build keeps those originals local and creates smaller deployment copies without altering them.
