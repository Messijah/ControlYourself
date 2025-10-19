# 📄 SÅ HÄR SKAPAR DU PDF AV GUIDEN

Det finns 3 enkla metoder. Välj den som passar dig bäst!

---

## 🚀 METOD 1: VIA SAFARI (ENKLAST!)

### Steg 1: Öppna guiden i Safari
```bash
open -a Safari APP_STORE_SUBMISSION_GUIDE.md
```

Eller:
1. Högerklicka på `APP_STORE_SUBMISSION_GUIDE.md` i Finder
2. Välj "Öppna med" → "Safari"

### Steg 2: Exportera som PDF
1. I Safari: **File → Export as PDF...**
2. Välj var du vill spara (t.ex. Desktop)
3. Namnge: `Urge_App_Store_Guide.pdf`
4. Klicka **Save**

✅ **Klart!** Du har nu en PDF!

---

## 📱 METOD 2: VIA PREVIEW (BRA FORMATERING)

### Steg 1: Öppna i TextEdit
```bash
open -a TextEdit APP_STORE_SUBMISSION_GUIDE.md
```

### Steg 2: Skriv ut
1. **Command + P** (eller File → Print)
2. Längst ner till vänster: Klicka på **PDF** dropdown
3. Välj **"Save as PDF"**
4. Namnge: `Urge_App_Store_Guide.pdf`
5. Klicka **Save**

✅ **Klart!**

---

## 💻 METOD 3: VIA TERMINAL (FÖR NERDAR)

### Om du har Homebrew installerat:

```bash
# Installera pandoc (one-time)
brew install pandoc
brew install --cask basictex

# Skapa PDF
cd /Users/jens/Desktop/ControlYourself
pandoc APP_STORE_SUBMISSION_GUIDE.md \
    -o Urge_App_Store_Guide.pdf \
    --pdf-engine=xelatex \
    -V geometry:margin=2.5cm \
    -V fontsize=11pt \
    --toc

# Öppna PDF
open Urge_App_Store_Guide.pdf
```

✅ **Klart!** Professionell PDF skapad!

---

## 🎨 METOD 4: ONLINE (INGEN INSTALLATION)

### Via Markdown to PDF Converter:

1. Gå till: **https://www.markdowntopdf.com/**
2. Öppna `APP_STORE_SUBMISSION_GUIDE.md` i TextEdit
3. Kopiera ALLT innehåll (Command + A, Command + C)
4. Klistra in på webbsidan
5. Klicka **"Convert to PDF"**
6. Ladda ner PDF:en

✅ **Klart!**

---

## 📋 VILKET ALTERNATIV REKOMMENDERAR JAG?

### 🏆 **BÄST: Metod 1 (Safari)**
- ✅ Enklast
- ✅ Bra formatering
- ✅ Ingen installation
- ✅ Tar 30 sekunder

### 🥈 **BRA: Metod 2 (Preview via TextEdit)**
- ✅ Inbyggt i macOS
- ✅ Snygg formatering
- ✅ Tar 1 minut

### 🥉 **NÖRD: Metod 3 (Pandoc)**
- ✅ Professionellt resultat
- ✅ Bästa formatering
- ⚠️ Kräver installation

---

## 🎯 MITT FÖRSLAG:

**Kör detta i Terminal:**

```bash
open -a Safari /Users/jens/Desktop/ControlYourself/APP_STORE_SUBMISSION_GUIDE.md
```

Sedan i Safari: **File → Export as PDF**

**DONE!** 🎉

---

## 📍 VAR HITTAR JAG GUIDEN?

```
/Users/jens/Desktop/ControlYourself/APP_STORE_SUBMISSION_GUIDE.md
```

Eller:
```bash
cd /Users/jens/Desktop/ControlYourself
ls -la *.md
```

---

## 💡 EXTRA TIP:

Om du vill ha **ännu finare PDF**, använd VS Code:

1. Öppna filen i VS Code
2. Installera extension: "Markdown PDF"
3. Command + Shift + P
4. Skriv: "Markdown PDF: Export (pdf)"
5. PDF skapas automatiskt!

---

**Lycka till med PDF-skapandet!** 📄✨
