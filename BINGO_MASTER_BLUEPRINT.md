# 🎰 LUMINOUS BINGO: THE EXTREME TWA BLUEPRINT

## 1. VISION & STRATEGY
**Goal:** $50 - $100 USD / Day (Auto-Mining profit).
**Platform:** Telegram Web App (TWA).
**Competitive Advantage:** Psychological Immersion (Casino Glow), Extreme Speed (Supabase), and Referral Loops.

---

## 2. TECHNICAL STACK (The Fast Way)
- **Frontend:** Flutter Web (optimized for mobile browser inside Telegram).
- **Backend/Real-time:** Supabase (PostgreSQL + Real-time).
- **Automation (House Draw):** Node.js or Python script (Cron job).
- **Hosting:** Vercel or Render (Free tier).

---

## 3. PROJECT SETUP (Step-by-Step)

### Step 1: Telegram Entry Point
1. Open `@BotFather` on Telegram.
2. `/newbot` -> Name: `Luminous Bingo` -> Username: `LuminousBingoBot`.
3. Save **API TOKEN**.
4. `/setmenubutton` -> Select Bot -> "Configure Menu Button".
5. Input URL: `https://your-app-url.web.app` (Placeholder for now).
6. Button Text: `🎰 PLAY BINGO & WIN`.

### Step 2: The Flutter Project
1. Open Terminal:
   ```bash
   flutter create luminous_bingo
   cd luminous_bingo
   flutter config --enable-web
   ```
2. Add Dependencies in `pubspec.yaml`:
   ```yaml
   supabase_flutter: ^2.0.0
   google_fonts: ^6.0.0
   audioplayers: ^5.0.0
   ```

### Step 3: Supabase Backend (Real-time)
1. Create project on `supabase.com`.
2. **Table `game_state`**:
   - `id`: 1 (Fixed)
   - `called_numbers`: int[]
   - `current_call`: int
   - `prize_pool`: decimal
   - `status`: "WAITING" | "STARTED"
3. **Table `users`**:
   - `telegram_id`: text (Primary Key)
   - `balance`: decimal (Default: 0)
   - `referral_count`: int

---

## 4. UI ENHANCEMENTS (Extreme Beauty)
- **Neon Glassmorphism:** Deep purple background, frosted glass panels for stats.
- **Haptic Feedback:** Vibrate the phone when a number is called.
- **Dopamine Loop:** Confetti animations on "BINGO!" claim.

---

## 5. REVENUE & RETENTION LOGIC
- **Automatic House Cut:** 12.5% taken from every `prize_pool` before payout.
- **AdMob Strategy:** Interstitial ads on the "Next Game Starting in..." screen.
- **Referral Loop:** "Give 5 ETB, Get 5 ETB" automated logic.
- **Wallet Automation:** Telebirr Screenshot upload -> Admin Dashboard -> Instant Credit.
