# 🚗 Ajopäiväkirja

Mobiilisovellus ajokilometrien ja autokulujen seurantaan Android- ja iOS-laitteille.

## ✨ Ominaisuudet

### 🏠 Etusivu
- Kokonaiskilometrit ja kuukauden kilometrit
- Työajo vs. yksityisajo -jakauma
- Viikon kilometrigraafit
- Viimeisimmät 5 matkaa
- Pull-to-refresh

### ✍️ Matkan kirjaus
- Päivämäärän valinta
- Työajo/Yksityisajo-valinta
- Matkamittarilukema (alku + loppu)
- GPS-paikannus lähtö- ja kohdeosoitteelle
- Lisätiedot

### 💰 Kulut
- Kokonaiskulut ja kuukausittaiset kulut
- 11 kategoriaa (Polttoaine, Huolto, Korjaus, jne.)
- Polttoainetilastot
- Kuittien tallennus
- Pie- ja Bar-chartit

### ⚙️ Asetukset
- Tilastot
- CSV-vienti ja -tuonti
- Varmuuskopiointi (ZIP-tiedostot)
- Kaikkien tietojen poisto

### 📊 Historia
- Vuoden kilometrit graafina
- Kaikki matkat listana

### 💎 Premium-tilaus
- Ilmainen 30 päivän kokeilu
- Kuukausi- ja vuositilaus
- Automaattinen varmuuskopiointi
- Kehittyneet tilastot
- PDF-vienti

## 🛠️ Teknologia

- **Flutter 3.38.5** - Cross-platform kehitys
- **Dart 3.10.4** - Ohjelmointikieli
- **Provider** - State management
- **SQLite** - Paikallinen tietokanta
- **fl_chart** - Graafit
- **Geolocator & Geocoding** - GPS-paikannus
- **in_app_purchase** - Tilaukset

## 🚀 Asennus ja käyttö

### Esivaatimukset
- Flutter SDK 3.38.5 tai uudempi
- Android Studio / Xcode
- Android SDK 36+ tai iOS 13+

### Asennus

1. Asenna riippuvuudet:
```bash
flutter pub get
```

2. Käynnistä sovellus:
```bash
flutter run
```

### Android-buildi
```bash
flutter build apk --release
```

### iOS-buildi
```bash
flutter build ios --release
```

## 🎨 Värimaailma

- **Pääväri:** #FF1919 (Kirkkaanpunainen)
- **Toissijainen:** #191919 (Tummanharmaa)
- **Yksityisajo:** #666666 (Harmaa)
- **Tausta:** #F5F5F5 (Vaaleanharmaa)
- **Kortit:** #FFFFFF (Valkoinen)

## 📱 Oikeudet

### Android (AndroidManifest.xml)
- `ACCESS_FINE_LOCATION` - GPS-paikannus
- `ACCESS_COARSE_LOCATION` - Epätarkka sijainti
- `READ_EXTERNAL_STORAGE` - Tiedostojen luku
- `WRITE_EXTERNAL_STORAGE` - Tiedostojen kirjoitus
- `CAMERA` - Kameran käyttö

### iOS (Info.plist)
- `NSLocationWhenInUseUsageDescription` - Sijaintipalvelut
- `NSCameraUsageDescription` - Kamera
- `NSPhotoLibraryUsageDescription` - Kuvagalleria

## 📄 Tietorakenne

### Trips (matkat)
- date, tripType, startOdometer, endOdometer
- startAddress, endAddress
- startLat, startLon, endLat, endLon
- notes

### Expenses (kulut)
- date, category, amount
- company, liters, pricePerLiter
- receiptPath, notes

## 🔄 Varmuuskopiointi

- **Matkat:** CSV-vienti/tuonti
- **Kulut:** ZIP-paketti (CSV + kuitit)
- Tuki esimerkki-CSV-tiedostoille

## 💳 Tilausmallit

### Ilmainen kokeilu
- 30 päivää täydet ominaisuudet
- Automaattinen aktivointi ensimmäisellä kerralla

### Kuukausitilaus
- Kaikki premium-ominaisuudet
- Peruutettavissa milloin tahansa

### Vuositilaus
- Kaikki premium-ominaisuudet
- Säästä 20% kuukausihintaan verrattuna

## 📝 Lisenssi

Kaupallinen sovellus. Kaikki oikeudet pidätetään.

---

**Versio:** 1.0.0  
**Päivitetty:** 16.12.2025
