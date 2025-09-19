
# What?f — Flutter app (FULL, locale)

**Feature incluse**
- Bottom navigation (Home / Cronologia / Esplora)
- Percorso guidato (generiche → tema → mirate + testo libero)
- "Apri la porta" + animazione porta, "Rigenera" solo se modifichi l'input
- Due scenari AI (Sliding Doors / What the F?!) con short/long, probabilità, rationale, "Vedi di più"
- Condivisione testo (share_plus), Audio TTS (flutter_tts)
- Cronologia locale + limite 3 domande/giorno
- Like locali + Top 10 mock
- Tema dark/violaceo + light
- GitHub Actions (APK build) + Dev Container (Codespaces) pronti

## Avvio locale (se hai Flutter)
```bash
flutter pub get
flutter run --dart-define=OPENAI_API_KEY=sk-...LA_TUA_CHIAVE
