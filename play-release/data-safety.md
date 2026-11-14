# Google Play — Data Safety Form (accurate answers for Mezmure Dawit)

Fill these in under Play Console → App content → Data safety.

## Does your app collect or share any of the required user data types?
**Yes** (advertising ID, via Google Mobile Ads SDK).

## Security practices
- [x] Data is encrypted in transit — ad requests to Google are TLS-encrypted
- [x] You can request that data be deleted — users can reset/delete advertising ID in device settings; app-stored preferences can be cleared via Android settings
- [x] Data collection is not selective / app does NOT target children as primary audience

## Data types collected (declared by the Google Mobile Ads SDK)

### Device or other IDs
- **Collected:** Yes — Advertising ID
- **Shared:** Yes — with Google (and ad partners via AdMob)
- **Purpose:** Advertising or marketing; Analytics
- **Optional for users?** Yes — users may reset or delete the advertising ID in device settings
- **Ephemeral processing?** No
- **Collection for:** App functionality — No; Analytics — Yes (aggregated); Advertising & marketing — Yes; Personalization — Yes (ad personalization unless user opts out in Google settings)

### App activity
- **Collected:** No
- **App interactions are NOT collected or shared** (no analytics SDKs besides AdMob's aggregated reporting)

### Everything else (all No)
- Personal info: **Not collected** (no name, email, address, ID, location, phone)
- Financial info: **Not collected**
- Health & fitness: **Not collected**
- Messages: **Not collected**
- Photos and videos: **Not collected**
- Audio files: **Not collected**
- Files and docs: **Not collected**
- Calendar: **Not collected**
- Contacts: **Not collected**
- Location (approximate or precise): **Not collected**
- App info and performance: **Not collected / Not shared** (no crash reporting SDK)
- Web browsing history: **Not collected**

## Note
- Favorites, dark mode, font size are stored ONLY on-device via SharedPreferences. They are never transmitted.
- No accounts, no sign-in, no user-generated content, no chat.

## Advertising declaration
Play Console → App content → Ads → **Yes, my app contains ads**.
For closed testing you may ship with Google test ad units (safe to click). For production release, switch to your real AdMob units (see README, publishing checklist).
