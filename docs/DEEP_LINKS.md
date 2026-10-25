# Sharing and deep links

The share button on a product sends a short summary (price, fit, any dip below the 30-day average) and a link. Links open Clarion on the right screen. A notification tap goes through the same path (`DeepLinks.pending`).

## Links Clarion understands

| Screen | https (what Share sends) | Custom scheme |
| :--- | :--- | :--- |
| A product | `https://clarion-e08f0.web.app/p/<productId>` | `clarion://product/<productId>` |
| An order | `https://clarion-e08f0.web.app/orders/<orderId>` | `clarion://orders/<orderId>` |
| Browse | `https://clarion-e08f0.web.app/browse?category=Audio` | `clarion://browse?category=Audio` |

Parsing is in `lib/core/links/deep_links.dart`. Links are untrusted input, so:

- other hosts, schemes and paths are ignored;
- ids are checked against the catalogue and the account's own orders before anything opens; an unknown id does nothing;
- an order link only opens an order that belongs to the signed-in account;
- a link that arrives before sign-in waits until the account's app is open.

## Try it

```bash
adb shell am start -a android.intent.action.VIEW -d "clarion://product/hp_core"
adb shell am start -a android.intent.action.VIEW -d "clarion://browse?category=Audio"
```

## Making the https links open the app

`clarion://` links always open the app. The https links open it only once Android has **verified** that Clarion owns the domain. Until then they open in the browser. To verify:

1. Get the SHA-256 fingerprint of the signing key (the debug key for development):

   ```bash
   cd android && ./gradlew signingReport
   ```

2. Create `web/.well-known/assetlinks.json`:

   ```json
   [{
     "relation": ["delegate_permission/common.handle_all_urls"],
     "target": {
       "namespace": "android_app",
       "package_name": "com.example.clarion",
       "sha256_cert_fingerprints": ["<SHA-256 from step 1>"]
     }
   }]
   ```

3. Deploy it with Firebase Hosting (`flutter build web`, then `firebase deploy --only hosting`, with `build/web` as the hosting folder), so it is served at `https://clarion-e08f0.web.app/.well-known/assetlinks.json`.

4. Reinstall the app, then check:

   ```bash
   adb shell pm get-app-links com.example.clarion
   ```

Each teammate's debug key has a different fingerprint; list them all in the array.
