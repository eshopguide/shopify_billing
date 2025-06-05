# Frontend (Billing UI)

The Billing UI provides a user interface for managing billing operations in Shopify apps. It's built as a standalone component that can be embedded into Shopify admin interfaces. The billing UI is encapsulated in a shadow DOM and includes a custom polaris version, so that it is reusable in any Shopify app with any polaris version.

## Getting Started

1. Install dependencies:

   ```bash
   yarn install
   ```

2. Start development server:

   ```bash
   yarn dev
   ```

## Development

The application uses Vite for development and building. The development server will watch for changes and rebuild automatically. To see the UI, include it in any Shopify app using [`yarn link`](https://classic.yarnpkg.com/lang/en/docs/cli/link/)

## Integration

To use this billing UI in your Shopify app:

1. Import the component:

   ```javascript
   import { Billing } from "@eshopguide/shopify-billing";
   ```

2. Use it in your React component:
   ```javascript
   <Billing />
   ```

## Peer Dependencies

- react (>=16.8)
- react-dom (>=16.8)
- react-i18next (>=13.0)

## Release

Use tags as described in [README.md](/README.md)
