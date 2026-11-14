# Closed Testing (Google Play) — Runbook

## 0. Prerequisites
- Seller account / Play Console access (you have published apps already → good).
- The release AAB: `build/app/outputs/bundle/release/app-release.aab` (44.3 MB, versionCode 8, versionName 1.0.8, package `com.mezmuredawit.app`).
- Upload key fingerprint (for Play App Signing enrollment):
  SHA-256 AF:77:B9:46:43:64:E2:EF:1D:BB:CB:46:C5:90:2D:39:BD:E2:09:11:7F:70:DC:B4:22:54:7F:50:CC:E3:63:29
  (Play will re-sign with its own app signing key; keep the upload keystore safe — it is the only way to update the app.)

## 1. Create the app in Play Console
- Play Console → All apps → Create app
- App name: Mezmure Dawit
- Default language: English (United States)
- App or game: **App** · Free · **Does the app contain ads? Yes**
- Package identity: `com.mezmuredawit.app` (fixed — you chose it)
- App signing: **Play App Signing** (accept; upload key = our upload-keystore.jks)

## 2. Store listing
Use `store-listing.md`. Add the 7 phone screenshots, feature graphic, icon, and set category + contact details.

## 3. App content (Play Console → App content)
Work through every section — all can use the pre-written answers:
1. **Privacy policy** — paste the hosted URL of `privacy-policy.md` (must be a live URL)
2. **Ads** — Yes, contains ads (test units in closed testing are fine)
3. **App access** — All functionality available without login (everything is)
4. **Advertising ID** — Yes, the app uses one (via Google Mobile Ads SDK)
5. **Data safety** — use `data-safety.md`
6. **Content rating** — use `content-rating.md` questionnaire
7. **Target audience** — 13+ / general (do NOT select under-13 or the Families policy applies)
8. **Government apps / financial features / news / COVID / political** — all No
9. **Permissions declaration** — no special declarations (INTERNET permission comes from the Ads SDK; that's normal)

## 4. Create the closed test track
- Play Console → Testing → **Closed testing** → Create track (e.g. "alpha")
- Upload the AAB
- Testers: create a list/group of tester emails (Google accounts). Options: Closed testing by 20+ testers, or internal testing for up to 100 instantly (internal = zero review, fastest smoke test)
- Release notes: "First closed test — trilingual psalms, prayer schedule, favorites."
- Review → roll out to closed testing

## 5. Tester opt-in & review
- Share the opt-in link with your testers
- IMPORTANT (if your personal developer account was created before the Google rule change exemption or after Nov 2023): Google requires **≥12 (as of this writing; check your console banner) real testers opted-in and active for 14 continuous days** before you can apply for production. Plan accordingly.
- Closed testing itself goes live within hours (not days) — only a light review.

## 6. Going to production later
1. Swap test ad unit IDs → real AdMob IDs (`lib/ad_service_mobile.dart`) and test APPLICATION_ID → your real App ID (`android/app/src/main/AndroidManifest.xml`); bump `version: 1.0.9+9` (or as you like)
2. `flutter build appbundle --release`
3. Promote the closed-testing release (or upload fresh) to production, or submit for review after the 14-day tester requirement

## 7.0. GitHub Pages privacy policy (in this repo)

A ready-to-host policy lives at `docs/privacy.html` (with `.nojekyll`). To go live:

1. Push this repo to GitHub (see step 7.1)
2. Edit `docs/privacy.html` → replace `REPLACE-WITH-YOUR-CONTACT-EMAIL` with your email
3. Repo → **Settings → Pages → Build and deployment → Source: Deploy from a branch** → `main` / `/docs` → **Save**
4. Your policy URL will be `https://<you>.github.io/<repo>/privacy.html` — paste that into the store listing

## 7.1. Wiring CI/CD (already configured for you in `.github/workflows/release.yml`)

One-time setup on GitHub (repo must exist first):

1. Create a **private** GitHub repository (empty, no README) named e.g. `mezmure_dawit`; give me its URL and I will push the current tree
2. Google Cloud: in the project linked to your Play Console account, create a **service account** (or reuse one) with these roles: *Service Account User* is not required; just create the SA and download its JSON key
   - Play Console → **Setup → API access** → link an existing Google Cloud project (or create one)
   - Create service account → grant it **Release manager** (or "Account permissions → Release manager") on the Play Console
   - Create a JSON key for it
3. In the GitHub repo → **Settings → Secrets and variables → Actions** add:
   - `PLAY_STORE_CONFIG` → contents of the service account JSON
   - `PLAY_KEYSTORE_BASE64` → base64 of `android/upload-keystore.jks` (`base64 -w0 android/upload-keystore.jks` on Linux/WSL, `certutil -encode` or `[Convert]::ToBase64String([IO.File]::ReadAllBytes('android/upload-keystore.jks'))` on Windows PowerShell)
   - `PLAY_KEYSTORE_PASSWORD` → store password (`android/key.properties`)
   - `PLAY_KEY_PASSWORD` → key password
   - `PLAY_KEY_ALIAS` → `upload`
4. From then on: pushing a tag `release-1.0.8` deploys to **internal testing** automatically; the **Run workflow** button lets you pick `internal` / `alpha` (closed) / `production`

Notes:
- First Play release for this app must be uploaded **manually** once (Play requires the first AAB to go through the console and Play App Signing enrollment); CI/CD takes over from the second release onward. Actually — the Play Developer API **can** upload the very first release to internal testing; you still must accept "Play App Signing" terms in the console once when creating the app.
- The service account JSON is a secret — the repo should stay private (it contains a signing-linked key)
- `key.properties` and `upload-keystore.jks` remain local-only; CI reconstructs them from secrets

## 7. Auto-deployment (when you're ready to wire it up)
Plan: GitHub Actions → build AAB → upload AAB to the closed testing track via the Google Play Developer API.

What I need from you to set it up:
1. The project pushed to a GitHub repository (currently local-only)
2. A Google Cloud **service account** in the project linked to your Play Console account (Play Console → Setup → API access → Create service account) with **Release manager** permission in the Play Console
3. The service account JSON key added as a GitHub repository secret (e.g. `PLAY_STORE_CONFIG`)
4. Choice: auto-deploy to **Internal testing** on every push to main, or on tagged releases (recommended)

I will then add `.github/workflows/release.yml` that: checks out, sets up Java + Flutter, runs analyze + tests, builds the AAB, and uploads it to your chosen track with the Google Play Developer API (`r0adkll/upload-google-play` or raw API call).
