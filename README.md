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
| `SETUP-TRACKER.bat` | Downloads Traccar server, installs it as an auto-start Windows service, installs Tailscale, opens the dashboard + login |
| `SHOW-PHONE-ADDRESS.bat` | Prints the exact URL to type into the phone app |
| `TUTORIAL.html` | Step-by-step illustrated guide with troubleshooting |

## Quick start

1. **PC:** double-click `SETUP-TRACKER.bat` → sign in to Tailscale with GitHub (one time)
2. **PC:** open `http://localhost:8082` → login `admin`/`admin` → **change the password**
3. **PC:** double-click `SHOW-PHONE-ADDRESS.bat` → note the address (like `http://100.x.y.z:8082`)
4. **Phone:** install [Traccar Client](https://github.com/traccar/traccar-client/releases/latest) (APK or App Store) + Tailscale → paste the address → copy the Device Identifier
5. **PC:** dashboard → Devices → Add → paste the identifier → watch the dot move

Full details with screenshots-level specificity: open `TUTORIAL.html`.

## Versions (verified at release)

- Traccar server **v6.16.0** — https://github.com/traccar/traccar
- Traccar Client **v10.2.4** (Android APK, 68 MB) — https://github.com/traccar/traccar-client/releases
- Tailscale (stable) — https://pkgs.tailscale.com/stable/

## The honest caveat

The server runs on your PC. **PC on = live tracking. PC off/asleep = history pauses** during that window. For 24/7 tracking, move the same Traccar server to a small cloud VM (any ₹200+/month VPS or an Oracle free tier) — the rest of the setup is identical.

## Responsible use

Track **your own devices**, or other people only with their knowledge and consent. Covert tracking of another person's phone or vehicle is a criminal offence in many jurisdictions (in India: IPC §354D stalking, up to 3 years). This kit is built for families who all agree to share — the mutual-consent model.

## Credits

- [Traccar](https://www.traccar.org/) by Anton Tananaev & contributors — the tracking platform (Apache-2.0)
- [Tailscale](https://tailscale.com/) — the private-network layer (client open source)
- Setup scripts and tutorial: MIT, do whatever you want.

## License

MIT — see [LICENSE](LICENSE).
