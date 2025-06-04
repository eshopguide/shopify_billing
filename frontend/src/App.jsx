import { AppProvider } from "polaris-13";
import ReactShadowRoot from "react-shadow-root";
import styles from "polaris-13/build/esm/styles.css?raw";

import BillingPage from "./pages/Billing";
import { BillingProvider } from "./providers/BillingProvider";

export default function Billing(props) {
  return (
    <div>
      <ReactShadowRoot>
        <style>
          {styles
            .replaceAll(":root", ":host")
            .replaceAll("html", ":host")
            .replaceAll("body", ":host")}
        </style>
        <AppProvider>
          <BillingProvider {...props}>
            <BillingPage />
          </BillingProvider>
        </AppProvider>
      </ReactShadowRoot>
    </div>
  );
}
