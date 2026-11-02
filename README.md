# Photo Portfolio

A static photography portfolio with a repeatable build and deployment workflow.

## Project layout

- `Photography_Site.html` is the editable source page.
- `Croatia Best of Best/` contains local, full-resolution source photographs. It is excluded from Git.
- `scripts/Build-Site.ps1` creates optimized deployable files.
- `site/` is the generated site committed to Git and published by Netlify.
- `.github/workflows/pages.yml` publishes `site/` to GitHub Pages after every push to `main`.

## Build locally

From PowerShell in the project directory:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Build-Site.ps1"
```

Optional quality controls:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Build-Site.ps1" -MaxDimension 2400 -JpegQuality 82
```

Open `site/index.html` for a quick file preview. For a more accurate local web preview, serve the `site` directory with a local HTTP server.

Run the build again whenever the HTML or source photographs change. Commit the updated files under `site/`.

## First deployment: GitHub Pages

1. Create a Git repository in this project directory.
2. Commit the project and publish it to a new public GitHub repository.
3. In the repository's **Settings → Pages**, set **Source** to **GitHub Actions** if it is not selected automatically.
4. Open the **Actions** tab and watch the **Deploy to GitHub Pages** workflow.
5. When it completes, GitHub provides a public HTTPS URL in the deployment summary.

After setup, the normal release loop is:

1. Edit the source page or photographs.
2. Run the build command above.
3. Review the generated site locally.
4. Commit and push.
5. GitHub Actions automatically deploys the pushed commit to GitHub Pages.

## Why the source photos are not committed

The original photographs are roughly 22–27 MB each and are unsuitable for routine mobile delivery or a lightweight Git repository. The build keeps those originals local and creates smaller deployment copies without altering them.
