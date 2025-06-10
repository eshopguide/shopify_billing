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
