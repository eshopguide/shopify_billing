import { createContext, useContext } from "react";

export const BillingContext = createContext();

export function BillingProvider({ children, fetch, locale, showToast }) {
  return (
    <BillingContext.Provider value={{ fetch, locale, showToast }}>
      {children}
    </BillingContext.Provider>
  );
}

export function useBilling() {
  return useContext(BillingContext);
}
