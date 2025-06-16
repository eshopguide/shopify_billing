# Migration für bestehende Apps

## Step 1: Billing Gem installieren

- `gem "shopify_billing", "x.x.x", github: "eshopguide/shopify_billing"`
- Gem noch nicht einrichten – wir brauchen erstmal nur das Charge Model!

## Step 2: Charges importieren

- Bei Charge Creation im ALTEN BILLING muss eine Charge in der DB angelegt werden, damit keine Lücke zwischen Import und neuer Logik entsteht
- Alle aktiven recurring Charges per Rake-Task importieren

## Step 3: Migration der Billing Logik

- Billing Logik aus der App entfernen
- Einrichtung des `shopify_billing` Gems s. [README.md](/README.md)

### Funktionen implementieren
- `Shop`
-- `after_activate_one_time_purchase()`: Wird ausgeführt, nachdem eine OneTime Charge aktiviert wurde
-- `send_plan_mismatch_notification()`: Wird ausgeführt, wenn ein Plan Mismatch besteht. Soll eine Benachrichtigung an den Shop-Owner schicken, dass ein neuer Plan abgeschlossen werden muss.

- `ApplicationController`
-- `shopify_host()`: Liefert den Shopify Host
-- `redirect_to_admin()`: Leitet zur Admin UI weiter

- `AuthenticatedController`
-- `current_shop()`: Liefert den aktuellen Shop

### Webhooks registrieren
- shop/update Webhook --> `ShopifyBilling::CheckPlanMismatchService.call(shop:)`
