# Security Policy

## Reporting a vulnerability

Please **do not open a public issue** for security problems.

Report privately through GitHub: go to the repository's **Security** tab → **Report a vulnerability**. Include steps to reproduce and the impact. You should get a reply within 7 days.

## What counts

- Ways the app could leak or expose the user's Gemini API key
- Ways the AI coach could change habits or history without the user pressing **Schedule**
- Ways data could leave the device other than the documented Gemini requests
- Secrets accidentally committed to this repository

## If you leaked your own API key

If you pasted your Gemini key somewhere public (an issue, a screenshot, a commit), delete it right away at [aistudio.google.com/apikey](https://aistudio.google.com/apikey) and create a new one. Deleting the text is not enough, because it may already be cached.

## Supported versions

Only the latest release and the `main` branch receive fixes.
