# Wakeon iOS release checklist

This document separates work that is complete in the repository from setup
that must be performed in Apple, Google, and Firebase consoles.

## Values implemented in the app

- Bundle ID: `com.alpwarestudio.wakeon`
- AdMob iOS app ID: `ca-app-pub-5963947262278027~3318050597`
- AdMob iOS banner: `ca-app-pub-5963947262278027/1630132627`
- AdMob iOS interstitial: `ca-app-pub-5963947262278027/2615911230`
- App Store non-consumable product ID: `wakeon_premium_ios`
- Android product ID remains separate: `wakeon_premium`

Release builds use the production iOS ad units above. Debug and profile builds
use Google's iOS test units. Android release units can only be supplied through
the Android-specific Dart defines documented in the README.

## App Store Connect

1. Create the iOS app record with bundle ID `com.alpwarestudio.wakeon`.
2. Accept the Paid Apps Agreement and complete banking and tax information.
3. Under Monetization > In-App Purchases, create a **Non-Consumable**:
   - Reference name: `Wakeon Premium – Remove Ads`
   - Product ID: `wakeon_premium_ios` (must match exactly)
   - Add English and Turkish display names/descriptions, price, availability,
     review screenshot, and review notes.
4. Add the first IAP to the same review submission as the first app version.
5. Test purchase and restore with a Sandbox Apple Account and TestFlight. Store
   metadata can take up to an hour to appear in the sandbox.
6. Complete App Privacy from the actual Xcode privacy report and current SDK
   behavior. AdMob may process Device ID, coarse location derived from IP,
   advertising data, product interaction, crash, performance, and diagnostic
   data. Firebase Analytics and Remote Config add their own disclosures. Mark
   data used for cross-app/site tracking when personalized advertising is
   enabled; do not claim that the app does not track while declaring tracking
   data elsewhere.
7. Provide the public privacy-policy URL and ensure it serves the updated policy
   in this repository.

The current Google Mobile Ads disclosure reference is:
https://developers.google.com/admob/ios/privacy/data-disclosure

The current Firebase Apple disclosure reference is:
https://firebase.google.com/docs/ios/app-store-data-collection

## AdMob and consent

1. Confirm the iOS app and both ad units are active in AdMob.
2. In Privacy & messaging, publish the consent messages required for the
   selected countries/regions. Configure an iOS IDFA explainer only if desired;
   the app safely rechecks ATT status, so the native prompt is never requested
   twice.
3. Link the final App Store listing to the AdMob iOS app after it is available.
4. Configure separate iOS Firebase app files before relying on Analytics or
   Remote Config. Do not reuse Android Firebase configuration.
5. Verify the UMP privacy-options entry appears under Settings when required.

## Required device checks

- Fresh install: regional consent UI, if required, appears before ATT.
- ATT appears only once and the app remains fully usable after **Ask App Not to
  Track**.
- No production ad is requested before UMP and ATT resolve.
- Firebase Analytics starts disabled and is enabled only after the applicable
  consent checks; on iOS it remains disabled when ATT is denied or restricted.
- Banner and interstitial use iOS ad-unit IDs; Android identifiers do not appear
  in the iOS release configuration.
- Settings > Premium is visible without login. The localized store price loads,
  purchase completes, ads disappear, and Restore Purchase works after reinstall.
- App Review can locate Premium without storefront or device restrictions.
- User-facing iOS screens contain no Google Play instructions or metadata.
- Local network permission text accurately describes discovery and wake use.

## Suggested App Review notes

> Wakeon is an ad-supported Wake-on-LAN utility. On a fresh installation, the
> App Tracking Transparency request appears during the first launch, after any
> regionally required consent message and before the first ad request. Denying
> ATT does not restrict any app feature; limited/contextual ads may still appear.
>
> The non-consumable in-app purchase can be found at: open Wakeon > tap the
> Settings icon > the Premium card is the first section > tap “Buy Premium”. The
> product identifier is `wakeon_premium_ios`. “Restore purchase” is directly
> below the purchase button. The purchase permanently removes banner and
> interstitial ads; all functional features are free before purchase.
>
> Please test the IAP in Apple's sandbox environment. No account or login is
> required. Wake-on-LAN can be reviewed by adding a sample device; purchasing
> Premium does not require access to local-network hardware.

## Archive gate

Before upload, run `flutter analyze`, `flutter test`, and an unsigned iOS release
build. In Xcode Organizer, inspect the archive's privacy report and confirm the
final bundle contains the production iOS AdMob app ID, the ATT purpose string,
and the current SKAdNetwork list.
