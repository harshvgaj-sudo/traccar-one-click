# Traccar One-Click 🎙️

**Your own location tracker in one double-click. No Google account. No subscriptions. Your data stays on your PC.**

A dead-simple setup kit that turns any Windows PC into a private GPS tracking server, and any phone into a tracker — using only free, open-source software and device-unique IDs instead of accounts.

## Why this exists

Every "find my family" app wants a Google login, a subscription, or both. This kit gives you:

- **No accounts** — each phone is identified by a unique Device ID generated inside the app. That ID *is* the login.
- **No cloud** — locations go from the phone to YOUR PC over your own private Tailscale network. Nobody else sees them.
- **No port forwarding** — Tailscale punches through CGNAT (Jio/Airtel included), works on home WiFi and mobile data with the same address.
- **Cross-platform** — Android (APK direct from GitHub, no Play Store needed) and iOS (App Store).
- **Everything open source** — Traccar (Apache-2.0), Tailscale client (BSD), this kit (MIT).

## What's in the box

| File | What it does |
|---|---|
| `SETUP-TRACKER.bat` | Downloads Traccar server, installs it as an auto-start Windows service, installs Tailscale, installs Simple View, opens the dashboard + login |
| `SHOW-PHONE-ADDRESS.bat` | Prints the exact URL to type into the phone app |
| `simple-view.html` | **Simple View** — our own clean personal viewer (single file, no build step). Auto-installed by the setup script. |
| `TUTORIAL.html` | Step-by-step illustrated guide with troubleshooting |

## Simple View (the missing piece we built)

The stock Traccar dashboard is built for fleets — powerful, but busy. `simple-view.html` is what a personal tracker should look like:

- **One map, your people** — OpenStreetMap tiles (no Google Maps, no API key, no billing)
- **Device cards** — online/offline/stale dot, speed, battery %, "updated 2 min ago"
- **Stale detection** — anything older than 10 minutes turns amber and says STALE, so a frozen pin never lies to you
- **Live via WebSocket** with automatic fallback to polling
- **Dark mode by default**, one-tap toggle
- **Zero dependencies to install** — one HTML file served by Traccar itself (same origin = no CORS, no extra server), works in any phone or desktop browser

Open it at `http://localhost:8082/simple-view.html` (or from anywhere: `http://<tailnet-ip>:8082/simple-view.html`). Login = your Traccar dashboard login.

MIT-licensed original code. Map tiles © OpenStreetMap contributors (fine for personal use). Leaflet 1.9 (BSD-2) from CDN.

## Quick start

1. **PC:** double-click `SETUP-TRACKER.bat` → sign in to Tailscale with GitHub (one time)
2. **PC:** open `http://localhost:8082` → login `admin`/`admin` → **change the password**
3. **PC:** double-click `SHOW-PHONE-ADDRESS.bat` → note the address (like `http://100.x.y.z:8082`)
4. **Phone:** install a tracker app (see below) + Tailscale → paste the address → copy the Device Identifier
5. **PC:** dashboard → Devices → Add → paste the identifier → watch the dot move

Full details with screenshots-level specificity: open `TUTORIAL.html`.

## Which phone apps to use (the simple-UI stack)

The Traccar *server* is the engine — it is boring, bulletproof infrastructure. For everyday use, these are the friendly faces on top (all verified maintained as of Oct 2026):

| Job | App | Why |
|---|---|---|
| **Send location (Android)** | [Colota](https://f-droid.org/packages/com.Colota) v1.21+ | Modern clean UI, dark mode, **queues points offline and back-fills when your PC comes back**, tracking profiles that auto-save battery, FOSS build with **zero Google Play Services**, AGPL-3.0, no telemetry |
| **Send location (Android, alternative)** | [Traccar Client](https://github.com/traccar/traccar-client/releases) v10.2+ | The official client, simplest possible two-field setup |
| **Send location (iPhone)** | Traccar Client (App Store) | Apple gives no other realistic choice for background GPS |
| **See everyone (phone)** | [Traccar Manager](https://github.com/traccar/traccar-manager) | One clean live map of all devices + notifications — much simpler than the web dashboard |

Colota's offline queue also softens the big caveat below: with Colota on Android, points recorded while the PC is off are **queued on the phone and back-filled automatically** when the server returns — history is delayed, not lost.

## Versions (verified at release)

- Traccar server **v6.16.0** — https://github.com/traccar/traccar
- Traccar Client **v10.2.4** (Android APK, 68 MB) — https://github.com/traccar/traccar-client/releases
- Traccar Manager — https://github.com/traccar/traccar-manager (updated Oct 2026)
- Colota **v1.21.0** (Android, F-Droid) — https://f-droid.org/packages/com.Colota
- Tailscale (stable) — https://pkgs.tailscale.com/stable/

## The honest caveat

The server runs on your PC. **PC on = live tracking. PC off/asleep = live view pauses.** With Colota on Android, locations recorded during that window are queued on the phone and sync back automatically — so history survives. On iOS there is no offline queueing; points during PC-off windows are simply not recorded. For true 24/7 live tracking, move the same Traccar server to a small cloud VM (any ₹200+/month VPS or an Oracle free tier) — the rest of the setup is identical.

## Responsible use

Track **your own devices**, or other people only with their knowledge and consent. Covert tracking of another person's phone or vehicle is a criminal offence in many jurisdictions (in India: IPC §354D stalking, up to 3 years). This kit is built for families who all agree to share — the mutual-consent model.

## Security audit (2026-10-31)

**File authenticity — measured, hashes pinned so tampering is detectable:**

| File | Size (B) | sha256 | Signature |
|---|---|---|---|
| `traccar-setup.exe` (6.16.0) | 188,277,098 | `23092f77…26f4cf9` | Not signed (upstream ships unsigned) |
| `tailscale-setup.exe` (1.104.4) | 1,394,992 | `74d30047…4b833d929` | **Valid — Tailscale Inc.** |
| `Traccar-Client-10.2.4.apk` | 71,458,896 | `4108250e…456897e19` | **Matches upstream-published hash** |
| `Colota-1.21.0.apk` | 45,888,137 | `0e2834e6…86666b7d` | F-Droid-signed (verified at install) |

**Attack surface found and FIXED in this kit:**
1. **CDN supply-chain risk** — Leaflet loaded without Subresource Integrity. Fixed: `integrity` hashes pinned for both CSS and JS (a compromised CDN can no longer inject code into Simple View).
2. **Silent-install failure** — the setup script ran without admin rights. Fixed: self-elevates with one UAC prompt.
3. **LAN exposure of port 8082** — Traccar binds all interfaces, and Windows often grants Java inbound access on Private networks. Fixed: the installer adds firewall BLOCK rules for all private ranges (v4 + v6) — the dashboard is reachable **only from this PC (localhost) and your Tailscale devices** (100.64/10).

**Threat model after setup:**
- Who can open the dashboard: this PC + devices signed into YOUR Tailscale tailnet. Nobody else. No ports forwarded to the internet.
- Traffic inside Tailscale is WireGuard-encrypted end-to-end; plain HTTP inside the tailnet is acceptable.
- Device-protocol listener ports are disabled by default in Traccar; this kit enables none.
- The one weak point left is the dashboard password — the setup opens the page to change `admin`/`admin` immediately.
- Binaries are intentionally NOT committed to git (GitHub blocks >100 MB files); the hashes above are the integrity anchor — re-verify after any re-download.

**Not yet tested (needs the server actually installed):** live probing of the running dashboard — auth brute-force resistance, HTTP header audit, port scan. That is the final verification step, pending the owner's go-ahead.

## Credits

- [Traccar](https://www.traccar.org/) by Anton Tananaev & contributors — the tracking platform (Apache-2.0)
- [Tailscale](https://tailscale.com/) — the private-network layer (client open source)
- Setup scripts and tutorial: MIT, do whatever you want.

## License

MIT — see [LICENSE](LICENSE).
