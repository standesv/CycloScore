# CycloScore — app Android (Capacitor)

Score météo/conditions pour cyclistes (vélo taff + sortie sportive), sur le modèle de RideScore.
L'app web (`www/index.html`) est empaquetée en application Android via **Capacitor**, et
l'**AAB + l'APK signés** sont produits automatiquement par **GitHub Actions**.

- `appId` : `bzh.dargio.cycloscore`
- `appName` : CycloScore
- Données météo : Open-Meteo (gratuit, sans clé) — le score est calculé sur l'appareil.

---

## 1. Créer le repo et pousser

Dans le dossier du projet (après dézippage) :

```bash
git init
git add -A
git commit -m "CycloScore — projet Capacitor initial"
# crée le repo GitHub et pousse (GitHub CLI) :
gh repo create CycloScore --private --source=. --push
# …ou à la main si le repo existe déjà :
# git remote add origin https://github.com/<ton-compte>/CycloScore.git
# git branch -M main && git push -u origin main
```

## 2. Générer le keystore de signature

La clé de signature reste **chez toi** (ne jamais la committer). Génère-la une fois :

```bash
keytool -genkeypair -v -keystore cycloscore.keystore \
  -alias cycloscore -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass "MON_MDP_STORE" -keypass "MON_MDP_CLE" \
  -dname "CN=Dargio BZH, O=Dargio, C=FR"
```

> Tu peux aussi réutiliser le keystore de RideScore si tu veux garder la même clé de signature.
> Garde une sauvegarde du fichier `.keystore` : sans lui, impossible de mettre à jour l'app sur le Play Store.

Encode-le en base64 (pour le mettre en secret GitHub) :

```bash
# Linux / macOS
base64 -w0 cycloscore.keystore > keystore.b64
# Windows PowerShell
# [Convert]::ToBase64String([IO.File]::ReadAllBytes("cycloscore.keystore")) > keystore.b64
```

## 3. Déclarer les secrets GitHub

Repo → **Settings → Secrets and variables → Actions → New repository secret**. Crée :

| Secret | Valeur |
| --- | --- |
| `KEYSTORE_BASE64` | le contenu de `keystore.b64` |
| `KEYSTORE_PASSWORD` | `MON_MDP_STORE` |
| `KEY_ALIAS` | `cycloscore` |
| `KEY_PASSWORD` | `MON_MDP_CLE` |

## 4. Lancer le build

Le workflow `.github/workflows/android.yml` se déclenche à chaque push sur `main`, sur un tag `v*`,
ou manuellement (onglet **Actions → Build Android → Run workflow**).

À la fin du run, récupère les fichiers dans **Actions → le run → Artifacts** :

- `cycloscore-release-aab` → `app-release.aab` (à envoyer sur le Google Play Console)
- `cycloscore-release-apk` → `app-release.apk` (à installer directement sur un téléphone pour tester)

> Pour publier une version, pousse un tag : `git tag v1.0.0 && git push origin v1.0.0`.
> Pense à incrémenter `versionCode`/`versionName` dans `android/app/build.gradle` à chaque release.

---

## Développement local (optionnel)

```bash
npm install
npx cap sync android
npx cap open android      # ouvre Android Studio
```

Modifier l'app = éditer `www/index.html`, puis `npx cap sync android` avant de rebuilder.

## Notes

- **Géolocalisation** : les permissions sont déclarées dans le manifest. La recherche par ville
  (Open-Meteo geocoding) fonctionne sans géoloc. Pour une géoloc 100 % fiable en natif, on pourra
  ajouter le plugin `@capacitor/geolocation` dans une itération suivante.
- **Connexion requise** : l'app a besoin d'Internet pour la météo ; le dernier score est mis en cache
  pour un affichage hors ligne dégradé.
- **Runners** : le build tourne sur `ubuntu-latest` (SDK Android + Java 17 fournis par GitHub Actions),
  car un AAB/APK ne peut pas être produit dans l'environnement Claude (pas de SDK Android).
