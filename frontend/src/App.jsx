import { AppProvider, Badge, Card, Frame, Loading, Page } from "polaris-13";
import styles from "polaris-13/build/esm/styles.css?raw";
import ReactShadowRoot from "react-shadow-root";
import BillingPage from "./pages/Billing";
import { QueryProvider } from "./providers/QueryProvider";
import { LocalizationProvider } from "./providers/LocalizationProvider";
import { BillingProvider } from "./providers/BillingProvider";

export default function Billing(props) {
  return (
    <div>
      <ReactShadowRoot>
        <style>{styles.replace(":root", ":host")}</style>
        <AppProvider>
          <BillingProvider {...props}>
            <QueryProvider>
              <LocalizationProvider>
                <BillingPage />
              </LocalizationProvider>
            </QueryProvider>
          </BillingProvider>
        </AppProvider>
      </ReactShadowRoot>
    </div>
  );
}
