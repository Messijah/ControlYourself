# 🔧 GITHUB SETUP GUIDE - URGE APP
### Komplett guide för Privacy Policy & Support via GitHub

---

## 📋 VAD DU SKA GÖRA

1. Publicera Privacy Policy via GitHub Pages
2. Använda GitHub Issues för support
3. Få färdiga URLs för App Store Connect

**Total tid: 15-20 minuter**

---

## 🚀 STEG 1: SKAPA GITHUB REPOSITORY

### 1. Gå till GitHub

Öppna: **https://github.com/new**

Logga in om du inte redan är det.

### 2. Skapa nytt repository

```
Repository name: ControlYourself
Description: Urge - Control Your Habits iOS App
Visibility: ✓ Public (krävs för GitHub Pages)

[✓] Add a README file
[ ] Add .gitignore (vi gör det manuellt)
[ ] Choose a license (lägg till senare om du vill)
```

Klicka **"Create repository"**

---

## 📁 STEG 2: LADDA UPP PRIVACY POLICY

### Metod 1: Via GitHub Web Interface (Enklast)

1. I ditt nya repository, klicka **"Add file"** → **"Create new file"**

2. Skriv filename:
```
docs/privacy-policy.html
```

3. Kopiera hela innehållet från:
```
/Users/jens/Desktop/ControlYourself/docs/privacy-policy.html
```

4. Klistra in i text-fältet

5. Scrolla ner, skriv commit message:
```
Add Privacy Policy
```

6. Klicka **"Commit new file"**

### Metod 2: Via Terminal (Om du känner dig bekväm)

```bash
# Gå till din projekt-mapp
cd /Users/jens/Desktop/ControlYourself

# Initiera git (om inte redan gjort)
git init

# Lägg till remote (byt ut "Messijah" mot ditt GitHub-användarnamn)
git remote add origin https://github.com/Messijah/ControlYourself.git

# Lägg till docs-mappen
git add docs/

# Committa
git commit -m "Add Privacy Policy for App Store"

# Pusha till GitHub
git push -u origin main
```

---

## 🌐 STEG 3: AKTIVERA GITHUB PAGES

### 1. Gå till Settings

I ditt repository, klicka på **"Settings"** (längst till höger i menyn)

### 2. Hitta Pages

I vänstermenyn, scrolla ner till **"Pages"** under "Code and automation"

### 3. Konfigurera GitHub Pages

```
Source: Deploy from a branch
Branch: main
Folder: /docs
```

Klicka **"Save"**

### 4. Vänta 1-2 minuter

GitHub bygger din sida. Ladda om sidan efter 1-2 minuter.

Du ska nu se en grön box med texten:
```
✓ Your site is live at https://messijah.github.io/ControlYourself/privacy-policy.html
```

### 5. Testa din Privacy Policy URL

Öppna:
```
https://[ditt-github-username].github.io/ControlYourself/privacy-policy.html
```

**Exempel:**
```
https://messijah.github.io/ControlYourself/privacy-policy.html
```

Du ska nu se en snygg Privacy Policy-sida! 🎉

---

## 🎫 STEG 4: KONFIGURERA SUPPORT VIA GITHUB ISSUES

### 1. Aktivera Issues (om inte redan aktivt)

1. Gå till **"Settings"** i ditt repository
2. Scrolla ner till **"Features"**
3. Kolla att **"Issues"** är ✓ markerat

### 2. Skapa Issue Templates (Optional men rekommenderat)

Detta gör det lättare för användare att rapportera problem.

1. I ditt repository, klicka **"Issues"** → **"New issue"**
2. Klicka **"Set up templates"**
3. Välj **"Bug report"** → **"Add"**
4. Välj **"Feature request"** → **"Add"**
5. Klicka **"Propose changes"** → **"Commit changes"**

### 3. Skapa en välkomst-Issue

1. Klicka **"Issues"** → **"New issue"**
2. Title:
```
Välkommen till Urge Support! 👋
```
3. Description:
```markdown
# 👋 Välkommen till Urge Support!

Tack för att du använder Urge - Control Your Habits!

## 🐛 Rapportera en bugg
Om du hittat en bugg, vänligen skapa en ny issue med:
- Vad du gjorde
- Vad som hände
- Vad du förväntade dig skulle hända
- Skärmdumpar om möjligt
- Din iOS-version och iPhone-modell

## 💡 Föreslå en funktion
Har du en idé för en ny funktion? Skapa en issue och berätta!

## ❓ Ställ frågor
Har du en fråga? Skapa en issue så svarar vi så fort vi kan!

---

**Privacy:** All support hanteras offentligt här på GitHub. Dela aldrig personlig information eller betalningsuppgifter i issues.
```

4. Label: Documentation
5. Klicka **"Submit new issue"**
6. Klicka **"Pin issue"** (så den alltid visas överst)

### 4. Din Support URL

```
https://github.com/[ditt-username]/ControlYourself/issues
```

**Exempel:**
```
https://github.com/Messijah/ControlYourself/issues
```

---

## 📝 STEG 5: URLS FÖR APP STORE CONNECT

Nu har du ALLT du behöver för App Store!

### Privacy Policy URL:
```
https://[ditt-username].github.io/ControlYourself/privacy-policy.html
```

### Support URL:
```
https://github.com/[ditt-username]/ControlYourself/issues
```

### Marketing URL (optional):
Skapa en README.md på GitHub med info om appen, då blir detta din marketing URL:
```
https://github.com/[ditt-username]/ControlYourself
```

---

## 🎨 STEG 6: FÖRBÄTTRA DIN GITHUB README (OPTIONAL)

Skapa en snygg README för ditt repository:

### 1. Redigera README.md

I ditt repository, klicka på **README.md** → **Edit this file** (penna-ikonen)

### 2. Kopiera denna template:

```markdown
# 🎯 Urge - Control Your Habits

<div align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2017.4+-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Swift-5.9+-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge" />
</div>

<p align="center">
  <strong>Take control of your habits in a sustainable way.</strong><br>
  Instead of quitting entirely, Urge helps you find balance.
</p>

---

## ✨ Features

- ⏱️ **Smart Timer** - Customizable intervals with beautiful design
- 📊 **Statistics** - Track your progress over time
- 🔥 **Flexible System** - Panic mode for extra flexibility
- 🌙 **Dynamic Island** - Timer always visible (iPhone 14 Pro+)
- 🌍 **26 Languages** - Fully localized for global reach

## 📱 Download

Available on the App Store (Coming Soon!)

[Link will be added when app is live]

## 🔒 Privacy

Your privacy is our top priority. Urge:
- ✅ Stores all data locally on your device
- ✅ Never collects or shares personal information
- ✅ No tracking or analytics
- ✅ GDPR compliant

Read our full [Privacy Policy](https://messijah.github.io/ControlYourself/privacy-policy.html)

## 🐛 Support

Found a bug or have a feature request?

[Create an issue](https://github.com/Messijah/ControlYourself/issues)

## 📄 License

Copyright © 2025 Jens Eriksson Erikholm. All rights reserved.

This app is proprietary software. Source code is not available for distribution.

---

<p align="center">
  Made with ❤️ in Sweden
</p>
```

3. Byt ut "Messijah" mot ditt användarnamn överallt

4. Klicka **"Commit changes"**

---

## ✅ FÄRDIGT! CHECKLISTA

```
[✓] GitHub repository skapat
[✓] Privacy Policy uppladdad
[✓] GitHub Pages aktiverat
[✓] Privacy Policy URL fungerar
[✓] GitHub Issues aktiverat
[✓] Support URL fungerar
[✓] README skapad (optional)
```

---

## 🎯 NÄSTA STEG: ANVÄND I APP STORE CONNECT

När du fyller i App Information i App Store Connect:

### Privacy Policy URL:
```
https://[ditt-username].github.io/ControlYourself/privacy-policy.html
```

### Support URL:
```
https://github.com/[ditt-username]/ControlYourself/issues
```

### Marketing URL (optional):
```
https://github.com/[ditt-username]/ControlYourself
```

---

## 💡 TIPS & TRICKS

### Hantera Support Issues

När någon skapar en issue:

1. **Svara snabbt** - Inom 24 timmar om möjligt
2. **Var vänlig** - Även om det är en "dum" fråga
3. **Använd labels:**
   - `bug` - Rapporterad bugg
   - `enhancement` - Feature request
   - `question` - Fråga från användare
   - `duplicate` - Redan rapporterad
   - `wontfix` - Inte planerat att fixa

4. **Stäng lösta issues:**
   ```
   Tack för rapporten! Detta är nu fixat i version 1.1.
   ```

### Uppdatera Privacy Policy

Om du behöver ändra Privacy Policy:

1. Redigera filen på GitHub
2. Uppdatera "Last updated" datumet
3. Committa ändringarna
4. Ändringarna syns direkt på din GitHub Pages URL!

### Custom Domain (Advanced)

Om du vill använda din egen domän istället för github.io:

1. Köp domän (t.ex. `urgeapp.se`)
2. I GitHub Pages Settings, lägg till Custom Domain
3. Konfigurera DNS hos din domän-leverantör
4. Privacy Policy URL blir: `https://urgeapp.se/privacy-policy.html`

---

## 🆘 FEL OCH LÖSNINGAR

### Problem: GitHub Pages visar 404

**Lösning:**
1. Kolla att filen ligger i `/docs/privacy-policy.html`
2. Vänta 5-10 minuter efter aktivering
3. Kontrollera att repository är Public
4. Bygg om: Settings → Pages → Save igen

### Problem: Privacy Policy ser konstig ut

**Lösning:**
1. Kolla att hela HTML-koden kopierades
2. Testa öppna i olika browsers
3. Kontrollera att filen heter exakt `privacy-policy.html` (små bokstäver!)

### Problem: Kan inte hitta Issues-tabben

**Lösning:**
1. Settings → Features → Markera "Issues"
2. Ladda om sidan

---

## 📧 BEHÖVER DU HJÄLP?

Om något inte fungerar:

1. Kolla [GitHub Pages Documentation](https://docs.github.com/en/pages)
2. Kolla [GitHub Issues Guide](https://docs.github.com/en/issues)
3. Skapa en issue på din egen repository för att testa! 😄

---

**Lycka till med din GitHub-setup!** 🚀

Du har nu allt du behöver för App Store-submissionen!
