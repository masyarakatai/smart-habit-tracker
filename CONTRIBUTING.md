# Contributing to Habit Track

Thanks for helping! This is a small personal project, so please open an issue to discuss bigger changes before you start.

## Ground rules

- **Never commit secrets.** No API keys, keystores, `key.properties`, `.env` files or `google-services.json`. CI runs a secret scanner on every pull request and fails if it finds one.
- **The AI never changes data on its own.** Coach tools may only *propose* changes; the user applies them with **Schedule**. Pull requests that let the model write directly will not be merged.
- **Keep user data on the device.** Don't add analytics, ads or trackers.
- By contributing, you agree that your contribution is licensed under **GPL-3.0** (see [LICENSE](LICENSE)).

## Development setup

```bash
flutter pub get
flutter analyze   # must report no issues
flutter test      # must pass
flutter run       # Android device or emulator
```

To try the AI Coach, use your **own** free Gemini key (see the README) and enter it in the app's Settings. Never put it in code.

## Pull requests

1. Fork the repo and create a branch from `main`.
2. Keep changes focused; one feature or fix per pull request.
3. Add or update tests for logic changes (streaks, coach tools, plan executor).
4. Make sure `flutter analyze` and `flutter test` pass.
5. Describe **what** changed and **why**, with screenshots for UI changes.

## Reporting bugs

Open an issue with steps to reproduce, what you expected, what happened, your device and Android version. **Do not paste your API key** or full chat logs that contain personal information.

Security problems: see [SECURITY.md](SECURITY.md) instead of opening a public issue.
