# 📱 APP STORE SUBMISSION GUIDE - URGE (CONTROL YOURSELF)
### KOMPLETT STEG-FÖR-STEG GUIDE - DU KAN INTE MISSLYCKAS! 🚀

---

## 📋 INNEHÅLLSFÖRTECKNING

1. [Pre-flight Checklist](#1-pre-flight-checklist)
2. [Skapa App Store Connect Account](#2-skapa-app-store-connect-account)
3. [Certifikat & Provisioning Profiles](#3-certifikat--provisioning-profiles)
4. [Konfigurera App i Xcode](#4-konfigurera-app-i-xcode)
5. [Skapa App i App Store Connect](#5-skapa-app-i-app-store-connect)
6. [Konfigurera In-App Purchases](#6-konfigurera-in-app-purchases)
7. [Bygga & Arkivera Appen](#7-bygga--arkivera-appen)
8. [Ladda upp till App Store Connect](#8-ladda-upp-till-app-store-connect)
9. [Fyll i App-information](#9-fyll-i-app-information)
10. [Skicka in för Granskning](#10-skicka-in-för-granskning)
11. [Vanliga Problem & Lösningar](#11-vanliga-problem--lösningar)

---

## ✅ 1. PRE-FLIGHT CHECKLIST

### Kolla av INNAN du börjar:

- [ ] **Du har ett Apple Developer Account** (kostar $99/år)
- [ ] **Ditt företag/organisation är registrerat** (JensEH)
- [ ] **Du har en Mac med Xcode installerat** (version 15.3+)
- [ ] **Appen bygger utan fel i Xcode** ✓
- [ ] **Alla features fungerar korrekt** ✓
- [ ] **App-ikonen är klar** ✓ (Purple gradient version)
- [ ] **Du har screenshots redo** (behövs senare)
- [ ] **Privacy Policy URL** (obligatorisk för App Store)

### ✅ Vad som REDAN är klart i din app:

```
✓ Bundle ID: com.JensEH.ControlYourself
✓ Development Team: 63PV439858
✓ Version: 1.0
✓ Build Number: 1
✓ App Icon: KOMPLETT (Purple gradient)
✓ Localizations: 26 språk (sv, en, de, es, fr, it, pt, nl, etc.)
✓ In-App Purchase IDs: urge.plus.monthly & urge.plus.yearly
✓ Dynamic Island: Funktionell
✓ Live Activities: Funktionell
✓ Privacy: App Groups konfigurerade
```

---

## 🔐 2. SKAPA APP STORE CONNECT ACCOUNT

### Steg 1: Gå till Apple Developer

1. Öppna Safari/Chrome
2. Gå till: **https://developer.apple.com**
3. Klicka på **"Account"** uppe till höger
4. Logga in med ditt **Apple ID**

### Steg 2: Betala årlig avgift

1. Om du inte redan är medlem, klicka på **"Join the Apple Developer Program"**
2. Välj **"Individual"** eller **"Organization"** (baserat på din företagsform)
3. Fyll i all information
4. Betala **$99** (årlig avgift)
5. Vänta på godkännande (tar vanligtvis 24-48 timmar)

### Steg 3: Verifiera åtkomst

1. Gå till: **https://appstoreconnect.apple.com**
2. Logga in med samma Apple ID
3. Du ska nu se App Store Connect-panelen

> **VIKTIGT:** Om du inte ser någonting eller får felmeddelande, vänta 24 timmar efter betalning.

---

## 🔑 3. CERTIFIKAT & PROVISIONING PROFILES

### Varför behövs detta?

Apple kräver att alla appar signeras med certifikat för att bevisa att de kommer från en verifierad utvecklare.

### AUTOMATISK METOD (REKOMMENDERAS):

#### Steg 1: Öppna ditt Xcode-projekt

```bash
cd /Users/jens/Desktop/ControlYourself/ControlYourself
open ControlYourself.xcodeproj
```

#### Steg 2: Välj Project Settings

1. Klicka på **"ControlYourself"** (blå projekt-ikon) längst upp till vänster
2. Under **TARGETS**, välj **"ControlYourself"**
3. Klicka på fliken **"Signing & Capabilities"**

#### Steg 3: Aktivera Automatic Signing

1. Markera **"Automatically manage signing"**
2. Välj **Team: JensEH (63PV439858)** i dropdown
3. Bundle Identifier ska redan vara: **com.JensEH.ControlYourself**

#### Steg 4: Upprepa för Widget Extension

1. Under **TARGETS**, välj **"ControlYourselfWidgetExtension"**
2. Klicka på fliken **"Signing & Capabilities"**
3. Markera **"Automatically manage signing"**
4. Välj **Team: JensEH (63PV439858)**
5. Bundle Identifier ska vara: **com.JensEH.ControlYourself.ControlYourselfWidgetExtension**

> **✅ Xcode kommer nu automatiskt skapa alla certifikat och profiler du behöver!**

### MANUELL METOD (om automatisk inte fungerar):

<details>
<summary>Klicka här för manual process...</summary>

1. Gå till https://developer.apple.com/account/resources/certificates/list
2. Klicka **"+"** för att skapa nytt certifikat
3. Välj **"iOS Distribution (App Store and Ad Hoc)"**
4. Följ instruktionerna för att skapa CSR (Certificate Signing Request)
5. Ladda upp CSR och ladda ner certifikatet
6. Dubbelklicka certifikatet för att installera i Keychain

</details>

---

## ⚙️ 4. KONFIGURERA APP I XCODE

### Steg 1: Öppna Build Settings

1. I Xcode, klicka på **"ControlYourself"** (projekt-ikon)
2. Under **TARGETS**, välj **"ControlYourself"**
3. Klicka på **"General"**-fliken

### Steg 2: Verifiera alla inställningar

```
Display Name: Urge
Bundle Identifier: com.JensEH.ControlYourself ✓
Version: 1.0 ✓
Build: 1 ✓

Minimum Deployment: iOS 17.4 ✓
Supported Devices: iPhone & iPad ✓

App Icons Source: AppIcon ✓
```

### Steg 3: Verifiera Capabilities

1. Klicka på **"Signing & Capabilities"**
2. Kolla att följande är aktiverade:
   - ✓ App Groups (group.com.JensEH.ControlYourself)
   - ✓ Push Notifications
   - ✓ Background Modes (Optional)

### Steg 4: Lägg till Privacy Descriptions

1. Klicka på **"Info"**-fliken
2. Scrolla ner till **"Custom iOS Target Properties"**
3. Lägg till (om de inte finns):

```xml
NSUserTrackingUsageDescription: "Vi använder inte tracking. Denna behörighet krävs av StoreKit."
NSUserNotificationsUsageDescription: "För att meddela dig när din timer är klar."
```

**Så här lägger du till:**
1. Högerklicka på listan → "Add Row"
2. Sök efter "Privacy - Tracking Usage Description"
3. Skriv texten under "Value"
4. Upprepa för "Privacy - User Notifications Usage Description"

---

## 📱 5. SKAPA APP I APP STORE CONNECT

### Steg 1: Gå till App Store Connect

1. Öppna: **https://appstoreconnect.apple.com**
2. Logga in med ditt Apple ID
3. Klicka på **"My Apps"**

### Steg 2: Skapa ny app

1. Klicka på **"+"** (plus-knappen)
2. Välj **"New App"**

### Steg 3: Fyll i App Information

```
Platforms: iOS ✓
Name: Urge
Primary Language: Swedish (Sweden)
Bundle ID: com.JensEH.ControlYourself (välj från dropdown)
SKU: urge-control-2025 (unikt ID för dina register)
User Access: Full Access
```

> **SKU:** Kan vara vad som helst, men använd något unikt (t.ex. "urge-control-2025")

### Steg 4: Klicka "Create"

Din app är nu skapad! Vi fyller i mer information senare.

---

## 💰 6. KONFIGURERA IN-APP PURCHASES

### Varför göra detta nu?

Din app använder prenumerationer (subscription) för Urge Plus. Dessa måste skapas INNAN du laddar upp din app.

### Steg 1: Öppna In-App Purchases

1. I App Store Connect, klicka på din app **"Urge"**
2. I vänstermenyn, klicka på **"In-App Purchases"**
3. Klicka på **"+"** (Manage → Create New)

### Steg 2: Skapa Månatlig Prenumeration

1. Välj **"Auto-Renewable Subscription"**
2. Klicka **"Create"**

#### Reference Name & Product ID:
```
Reference Name: Urge Plus Monthly
Product ID: urge.plus.monthly ✓
```
> **VIKTIGT:** Product ID måste matcha exakt vad som finns i SubscriptionManager.swift!

#### Subscription Group:
```
Create New Subscription Group
Group Name: Urge Plus Subscriptions
```

#### Subscription Duration:
```
Duration: 1 month
```

#### Price:
```
Price: 49 SEK/month
(Välj "Sweden" och ange pris)
```

#### Subscription Localizations:
För **Svenska (Sweden)**:
```
Display Name: Urge Plus
Description: Få tillgång till alla premiumfunktioner i Urge. Hantera dina vanor med statistik, påminnelser och obegränsat antal substanser.
```

För **Engelska (US)**:
```
Display Name: Urge Plus
Description: Get access to all premium features in Urge. Manage your habits with statistics, reminders, and unlimited substances.
```

#### Review Information:
```
Screenshot (Optional): Lägg till en screenshot som visar PaywallView
Review Notes: Monthly subscription for Urge Plus premium features
```

3. Klicka **"Save"**

### Steg 3: Skapa Årlig Prenumeration

Upprepa steg 2, men med:
```
Reference Name: Urge Plus Yearly
Product ID: urge.plus.yearly ✓
Duration: 1 year
Price: 490 SEK/year (299 kr=10% rabatt jämfört med månadsvis)
```

#### För Svenska:
```
Display Name: Urge Plus Årsprenumeration
Description: Få tillgång till alla premiumfunktioner i Urge under ett helt år. Spara 17% jämfört med månatlig betalning!
```

#### För Engelska:
```
Display Name: Urge Plus Yearly
Description: Get access to all premium features in Urge for a full year. Save 17% compared to monthly!
```

### Steg 4: Konfigurera Free Trial

1. Under din månatlig prenumeration, hitta **"Introductory Offers"**
2. Klicka **"Add Introductory Offer"**

```
Offer Type: Free Trial
Duration: 7 days
```

3. Upprepa för årlig prenumeration
4. Klicka **"Save"**

### Steg 5: Submit for Review

1. För varje prenumeration, klicka **"Submit for Review"**
2. Vänta på godkännande (tar vanligtvis 1-2 dagar, kan gransk as samtidigt med appen)

---

## 🏗️ 7. BYGGA & ARKIVERA APPEN

### Steg 1: Välj korrekt Device

1. I Xcode, uppe till vänster bredvid "Play"-knappen
2. Klicka på device-väljaren
3. Välj **"Any iOS Device (arm64)"**

> **VIKTIGT:** Du måste välja "Any iOS Device" och INTE en simulator för att kunna arkivera!

### Steg 2: Rensa tidigare byggen

```bash
# I Xcode, välj från menyn:
Product → Clean Build Folder
# Eller tryck: Shift + Command + K
```

### Steg 3: Arkivera appen

1. I Xcode-menyn, välj: **Product → Archive**
2. Vänta medan Xcode bygger appen (tar 1-5 minuter)
3. Om du får ett fel, se [Vanliga Problem](#11-vanliga-problem--lösningar)

### Steg 4: Verifiera arkivet

När bygget är klart öppnas **"Organizer"**-fönstret automatiskt.

Du ska se:
```
ControlYourself
Version 1.0 (1)
Today at XX:XX
```

> **OM ORGANIZER INTE ÖPPNAS:** Gå till **Window → Organizer** (eller Shift + Command + O)

---

## ☁️ 8. LADDA UPP TILL APP STORE CONNECT

### Steg 1: Distribuera arkivet

1. I Organizer-fönstret, välj ditt arkiv
2. Klicka på **"Distribute App"**

### Steg 2: Välj distribution-metod

```
Välj: App Store Connect
```
Klicka **"Next"**

### Steg 3: Distribution options

```
[✓] Upload
[ ] Export (använd inte detta)
```
Klicka **"Next"**

### Steg 4: App Store Connect distribution options

```
[✓] Upload your app's symbols
[✓] Manage Version and Build Number (Automatically manage)
```

> Symboler hjälper dig debugga crashes senare

Klicka **"Next"**

### Steg 5: Signering

```
[✓] Automatically manage signing
```

Xcode kommer nu att:
- ✓ Verifiera certifikat
- ✓ Signera appen
- ✓ Signera Widget Extension
- ✓ Förbereda för uppladdning

Klicka **"Next"**

### Steg 6: Granska information

Dubbelkolla:
```
App: ControlYourself
Version: 1.0
Build: 1
Bundle ID: com.JensEH.ControlYourself
```

Klicka **"Upload"**

### Steg 7: Vänta på uppladdning

- Uppladdningen tar **5-20 minuter** beroende på hastighet
- Du ser en progress bar
- **STÄ NG INTE XCODE under uppladdningen!**

### Steg 8: Bekräftelse

När uppladdningen är klar får du meddelandet:
```
"Upload Successful"
```

> **OBS:** Det kan ta ytterligare **10-30 minuter** innan bygget syns i App Store Connect!

---

## 📝 9. FYLL I APP-INFORMATION

### Gå tillbaka till App Store Connect

1. Öppna: **https://appstoreconnect.apple.com**
2. Klicka på **"My Apps"**
3. Välj **"Urge"**

### Steg 1: Vänta på Processing

Under **"Build"**-sektionen ska du snart se:
```
iOS App
Version 1.0 (1)
Processing... ⏳
```

Vänta tills det står:
```
iOS App
Version 1.0 (1) ✓
```

### Steg 2: Länka bygget

1. Scrolla ner till **"Build"**
2. Klicka på **"+"** eller **"Select a build before you submit your app"**
3. Välj **1.0 (1)**
4. Klicka **"Done"**

### Steg 3: App Information

Klicka på **"App Information"** i vänstermenyn:

```
Primary Language: Swedish (Sweden) ✓

Category:
  Primary: Health & Fitness
  Secondary: Lifestyle

Price and Availability:
  Price: Free (gratis nedladdning, prenumerationer i appen)
  Availability: All countries
```

### Steg 4: Age Rating

1. Klicka på **"Age Rating"** → **"Edit"**
2. Svara på frågorna:

```
Unrestricted Web Access: NO
Simulated Gambling: NO
Mature/Suggestive Themes: NO
Violence: NO
Horror/Fear Themes: NO
Medical/Treatment Information: YES (välj "Infrequent/Mild")
Alcohol, Tobacco, or Drug Use: YES (välj "Infrequent/Mild" - eftersom appen hjälper MINSKA användning)
Profanity or Crude Humor: NO
Sexual Content or Nudity: NO
```

Rating blir: **12+** eller **17+** (beroende på Apples bedömning)

### Steg 5: App Privacy

1. Klicka på **"App Privacy"** i vänstermenyn
2. Klicka **"Get Started"**

#### Data Collection:
```
Q: Does your app collect data from this app?
A: NO

(Din app samlar INTE in någon data - allt lagras lokalt)
```

Om du ändå vill vara extra transparent:
```
Q: Does your app collect data from this app?
A: YES

Data Types:
- [✓] Health & Fitness (Usage data)
    - Purpose: App Functionality
    - Linked to User: NO
    - Used for Tracking: NO
```

3. Klicka **"Save"**

### Steg 6: Prepare for Submission

1. Klicka på **"1.0 Prepare for Submission"** i vänstermenyn

### Steg 7: Screenshots (VIKTIGT!)

Du behöver screenshots för:
- **iPhone 6.7" Display** (iPhone 15 Pro Max, 14 Pro Max, etc.)
- **iPhone 6.5" Display** (iPhone 11 Pro Max, XS Max, etc.)

#### Hur tar du screenshots i Simulator:

1. I Xcode: **Xcode → Open Developer Tool → Simulator**
2. Välj **iPhone 15 Pro Max**
3. Kör appen (Command + R)
4. Navigera till olika skärmar
5. Ta screenshots: **Command + S** (sparas på Skrivbordet)

#### Screenshots du behöver:

**MINST 3, MAX 10 screenshots. Rekommenderat: 5-6 bilder**

1. **Welcome Screen** (WelcomeView med purple gradient logo)
2. **Main Timer View** (LandingPageView med aktiv timer)
3. **Timer Ready State** (när timern är klar, visar grönt)
4. **Statistics View** (StatisticsView)
5. **Settings View** (SettingsView)
6. **(Optional)** PaywallView

#### Ladda upp screenshots:

1. Under **"6.7 iPhone Display"**, klicka **"+"**
2. Välj dina screenshots i ordning
3. Upprepa för **"6.5 iPhone Display"** (kan använda samma bilder)

### Steg 8: Promotional Text (valfritt)

```
Hantera dina impulser med precision. Sätt intervaller i 15-minuterssteg och låt appen trappa ned åt dig automatiskt vecka för vecka.
```

### Steg 9: Description

#### Svenska:
```
Urge hjälper dig att ta kontroll över dina vanor på ett hållbart sätt. Istället för att sluta helt, hjälper vi dig att hitta en balans.

HUVUDFUNKTIONER:

⏱️ SMART TIMER
• Precisa intervaller i 15-minuterssteg (15 min till 8 timmar)
• Visual countdown med beautiful design
• Uppmuntrande meddelanden under tiden

📈 AUTO-PROGRESSION
• Låt appen öka intervallet automatiskt vecka för vecka
• Ställ in mål och tidsram — appen sköter resten
• Nå ditt mål utan att tänka på det

📊 STATISTIK & FRAMSTEG
• Följ dina framsteg över tid
• Se ditt genomsnitt per dag
• Current streak och milestone-tracking

🔥 FLEXIBELT SYSTEM
• Panikläge för extra flexibilitet
• Anpassade inställningar för din livsstil
• Stöd för både snus och cigaretter

🌙 DYNAMIC ISLAND
• Timer alltid synlig i Dynamic Island (iPhone 14 Pro+)
• Live Activities på låsskärmen — lokaliserat på 26 språk
• Smidig upplevelse oavsett var du är

💎 URGE PLUS
• Fullständig statistik
• Obegränsat antal substanser
• 7 dagars gratis provperiod

Ta steget mot bättre balans idag. Ladda ner Urge och börja din resa.

Gjord med ❤️ i Sverige
```

#### Engelska:
```
Urge helps you take control of your habits in a sustainable way. Instead of quitting entirely, we help you find balance.

KEY FEATURES:

⏱️ SMART TIMER
• Precise intervals in 15-minute steps (15 min to 8 hours)
• Visual countdown with beautiful design
• Encouraging messages throughout

📈 AUTO-PROGRESSION
• Let the app increase your interval automatically week by week
• Set a target and timeframe — the app handles the rest
• Reach your goal without even thinking about it

📊 STATISTICS & PROGRESS
• Track your progress over time
• See your daily average
• Current streak and milestone tracking

🔥 FLEXIBLE SYSTEM
• Panic mode for extra flexibility
• Custom settings for your lifestyle
• Support for both snus and cigarettes

🌙 DYNAMIC ISLAND
• Timer always visible in Dynamic Island (iPhone 14 Pro+)
• Live Activities on lock screen — localized in 26 languages
• Smooth experience wherever you are

💎 URGE PLUS
• Complete statistics
• Unlimited substances
• 7-day free trial

Take the step toward better balance today. Download Urge and start your journey.

Made with ❤️ in Sweden
```

### Steg 10: Keywords

```
svenska: snus, cigaretter, rökning, vana, kontroll, balans, timer, självkontroll, hälsa, wellness
engelska: snus, cigarettes, smoking, habit, control, balance, timer, self-control, health, wellness
```

> Max 100 tecken! Använd komma för att separera.

### Steg 11: Support URL & Marketing URL

```
Support URL: https://jenserikssonerikholm.se/urge-support
Marketing URL: https://jenserikssonerikholm.se/urge (valfritt)
```

> **VIKTIGT:** Du MÅSTE ha en fungerande support-URL!

### Steg 12: Version Information

```
Version: 1.0
Copyright: 2025 JensEH
```

### Steg 13: App Review Information

Detta är vad Apple-granskarna ser:

```
Sign-In Required: NO

Contact Information:
  First Name: Jens
  Last Name: Eriksson Erikholm
  Phone: +46 [ditt telefonnummer]
  Email: [din email]

Notes:
App låter användare hantera sina vanor genom att sätta intervaller mellan användning.

För att testa prenumerationer:
- Använd Sandbox Test Account
- Månatlig prenumeration: urge.plus.monthly (49 SEK/mån)
- Årlig prenumeration: urge.plus.yearly (490 SEK/år)
- Båda har 7 dagars gratis provperiod

Huvudfunktioner att testa:
1. Välj substans (snus eller cigaretter)
2. Konfigurera inställningar (timer i 15-minuterssteg)
3. Starta timer
4. Använd "Panik"-knappen
5. Kontrollera Dynamic Island (iPhone 14 Pro+)
6. Besök Statistik-sidan
7. Testa Paywall (första gången appen startas)
8. Aktivera Auto-progression i inställningar (välj mål-intervall och antal veckor)

Appen använder ingen tracking och sparar all data lokalt.
```

### Steg 14: Version Release

```
Välj: Manually release this version
```

(Detta låter dig välja exakt när appen publiceras efter godkännande)

---

## 🚀 10. SKICKA IN FÖR GRANSKNING

### Sista kontrollen!

Gå igenom att ALLT är ifyllt:
- [✓] Screenshots uppladdade
- [✓] Description skriven (svenska & engelska)
- [✓] Keywords ifyllda
- [✓] Support URL fungerande
- [✓] Build vald
- [✓] In-App Purchases konfigurerade
- [✓] Privacy information fylld i
- [✓] Age Rating satt
- [✓] App Review Information fylld i

### Steg 1: Klicka "Add for Review"

1. Högst upp på sidan, klicka **"Add for Review"**

### Steg 2: Submit for Review

1. Klicka på **"Submit for Review"**
2. Bekräfta genom att klicka **"Submit"**

### 🎉 GRATTIS! Din app är nu inskickad!

```
Status: "Waiting for Review"
```

### Vad händer nu?

1. **Waiting for Review** (1-3 dagar)
   - Din app står i kö

2. **In Review** (1-2 dagar)
   - Apple granskar din app
   - De testar alla funktioner
   - De kollar att allt följer riktlinjer

3. **Pending Developer Release** (om godkänd)
   - Du kan nu släppa appen när du vill!
   - Klicka på **"Release this Version"**

4. **Ready for Sale** 🎉
   - Din app är LIVE på App Store!

### Om den avvisas:

1. Du får ett email med förklaring
2. Fixa problemen
3. Klicka **"Submit for Review"** igen
4. Vanliga problem finns i nästa sektion

---

## ⚠️ 11. VANLIGA PROBLEM & LÖSNINGAR

### Problem 1: "No signing certificate found"

**Fel:**
```
Code signing is required for product type 'Application' in SDK 'iOS XX.X'
```

**Lösning:**
1. Xcode → Preferences → Accounts
2. Välj ditt Apple ID → Klicka "Download Manual Profiles"
3. I projektet → Signing & Capabilities → Markera "Automatically manage signing"
4. Försök igen

---

### Problem 2: "Invalid Bundle Identifier"

**Fel:**
```
The bundle ID "com.JensEH.ControlYourself" cannot be used
```

**Lösning:**
1. Gå till https://developer.apple.com/account/resources/identifiers/list
2. Klicka **"+"** för att registrera Bundle ID
3. Välj "App IDs"
4. Description: "Urge Control Yourself"
5. Bundle ID: com.JensEH.ControlYourself
6. Capabilities: App Groups, Push Notifications
7. Klicka "Register"
8. Försök bygga igen

---

### Problem 3: "Missing compliance"

**Fel:**
```
Missing Export Compliance
```

**Lösning:**
1. I App Store Connect → Din app → "Prepare for Submission"
2. Scrolla ner till **"Export Compliance Information"**
3. Svara:
   ```
   Q: Does your app use encryption?
   A: NO (om du inte använder extra kryptering utöver HTTPS)
   ```
4. Spara och skicka in igen

---

### Problem 4: "Guideline 2.1 - Information Needed"

**Apple frågar:**
```
We need more information about your app's health-related features
```

**Lösning:**
Svara i Resolution Center:
```
Hej,

Urge är en app för vanavfänjning som hjälper användare att skapa hållbara vanor genom att:

1. Sätta intervaller mellan användning
2. Följa statistik över tid
3. Använda påminnelser för balans

Appen ger INTE medicinsk rådgivning eller behandling. Den är ett verktyg för självhjälp och vanavfänjning.

All data lagras lokalt på användarens enhet. Vi samlar inte in någon personlig information.

Vänligen,
Jens
```

---

### Problem 5: "In-App Purchase not showing"

**Symtom:** Prenumerationerna syns inte i appen

**Lösning:**
1. Kontrollera att Product IDs matchar exakt:
   - `urge.plus.monthly`
   - `urge.plus.yearly`
2. Vänta 2-4 timmar efter att du skapat dem i App Store Connect
3. Testa med StoreKit Configuration File först
4. I Xcode: Editor → StoreKit → Enable StoreKit Configuration

---

### Problem 6: "Widget not working after install"

**Symtom:** Dynamic Island/Live Activity fungerar inte

**Lösning:**
1. Kontrollera att Widget Extension är inkluderad i arkivet
2. I Xcode → Target → ControlYourselfWidgetExtension
3. Build Settings → Skip Install = NO
4. Arkivera på nytt

---

### Problem 7: "Build processing takes forever"

**Symtom:** Bygget står på "Processing" i över 1 timme

**Lösning:**
1. Detta är normalt! Apple's processing kan ta upp till 24 timmar
2. Kontrollera din email för notifications
3. Om det tar >48 timmar, kontakta Apple Support

---

### Problem 8: "Rejected for 2.3.10 - Accurate Metadata"

**Apple säger:**
```
Your app's screenshots do not accurately reflect the app
```

**Lösning:**
1. Se till att alla screenshots:
   - Kommer från faktiska app-vyer (inte mockups)
   - Visar aktuell version av appen
   - Inte innehåller text-overlays eller grafik utöver appen själv
2. Ladda upp nya screenshots
3. Skicka in igen

---

### Problem 9: "Privacy Policy Required"

**Fel:**
```
Your app requires a privacy policy
```

**Lösning:**
Skapa en enkel Privacy Policy. Exempel:

**privacy-policy.html:**
```html
<!DOCTYPE html>
<html>
<head>
    <title>Urge - Privacy Policy</title>
</head>
<body>
    <h1>Privacy Policy for Urge</h1>
    <p>Last updated: [Datum]</p>

    <h2>Data Collection</h2>
    <p>Urge does not collect, store, or share any personal data. All your information is stored locally on your device.</p>

    <h2>In-App Purchases</h2>
    <p>Payment information is processed by Apple and we do not have access to your payment details.</p>

    <h2>Contact</h2>
    <p>For questions: [din email]</p>
</body>
</html>
```

Lägg upp denna på en server och använd URL:en i App Store Connect.

---

### Problem 10: "TestFlight not working"

**Symtom:** Kan inte testa appen via TestFlight

**Lösning:**
1. I App Store Connect → Din app → TestFlight
2. Välj bygget
3. Under "Test Information", fyll i:
   - What to Test: "Test all features"
   - Email: [testers email]
4. Lägg till **Internal Testers** (upp till 100 stycken gratis)
5. Klicka "Save"
6. Tester får email inom 1 timme

---

## 🎯 EXTRA TIPS FÖR SUCCÉ

### 1. ASO (App Store Optimization)

**Titel:** "Urge - Control Your Habits"
- Korta, tydliga namn rankar bättre
- Inkludera nyckelord

**Subtitle (Optional):**
```
"Balance your urges, progress week by week"
```

**Keywords Research:**
Använd verktyg som:
- AppTweak
- Sensor Tower
- App Annie

### 2. Localization

Du har redan 26 språk! Detta ger:
- ✓ Större reach
- ✓ Bättre ranking globalt
- ✓ Fler nedladdningar

### 3. Launch Checklist

Innan du klickar "Release":
- [ ] Testa appen själv i 1 vecka
- [ ] Låt 3-5 personer beta-testa via TestFlight
- [ ] Förbered marknadsföring (social media posts, website)
- [ ] Skapa promo-video (valfritt)
- [ ] Kontakta tech-bloggar/influencers

### 4. Post-Launch

Efter publicering:
1. **Monitor Reviews** - Svara på alla recensioner inom 24h
2. **Track Analytics** - Använd App Analytics i App Store Connect
3. **Update Regularly** - Släpp updates var 4-6:e vecka
4. **A/B Test** - Testa olika screenshots/beskrivningar

---

## 📧 SUPPORT & KONTAKT

### Apple Developer Support

- **Email:** developer.apple.com/contact
- **Phone:** 1-800-633-2152 (USA)
- **Forum:** developer.apple.com/forums

### App Review Support

- **Direct Contact:** appstoreconnect.apple.com → Contact Us → App Review

### Resource Links

- **Human Interface Guidelines:** developer.apple.com/design/human-interface-guidelines
- **App Store Review Guidelines:** developer.apple.com/app-store/review/guidelines
- **In-App Purchase Guidelines:** developer.apple.com/in-app-purchase
- **TestFlight Guide:** developer.apple.com/testflight

---

## ✅ FINAL CHECKLIST INNAN SUBMISSION

Skriv ut och kolla av:

```
DEVELOPMENT:
[✓] Appen bygger utan fel
[✓] Alla features fungerar
[✓] Testat på riktigt iPhone
[✓] Dynamic Island testad (iPhone 14 Pro+)
[✓] In-App Purchases fungerar

ASSETS:
[✓] App Icon (1024x1024) ✓
[✓] Screenshots (minst 3)
[✓] Preview Video (valfritt)

APP STORE CONNECT:
[✓] App skapad
[✓] Build uppladdad
[✓] Description skriven
[✓] Keywords valda
[✓] Screenshots uppladdade
[✓] In-App Purchases konfigurerade
[✓] Privacy Policy länkad
[✓] Support URL fungerande
[✓] Age Rating satt
[✓] App Review Information fylld i

LEGAL:
[✓] Privacy Policy
[✓] Terms of Service (om applicable)
[✓] Developer Agreement accepterad
[✓] Paid Apps Agreement signerad

READY TO SUBMIT? ✅
```

---

## 🎉 LYCKA TILL!

Du har nu allt du behöver för att skicka in din app till App Store!

**Genomsnittlig tidslinje:**
- Förberedelser: 2-4 timmar
- Review process: 2-5 dagar
- Total tid till publicering: 3-7 dagar

**Du har byggt något fantastiskt!** 🚀

Om du kör fast, gå tillbaka till [Vanliga Problem](#11-vanliga-problem--lösningar) eller kontakta Apple Developer Support.

---

*Skapad med ❤️ av Claude Code*
*För Urge - Control Your Habits v1.1*
*Senast uppdaterad: 2026-02-14*
