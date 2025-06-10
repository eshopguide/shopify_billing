import { createContext, useContext } from "react";

export const BillingContext = createContext();

export function BillingProvider({ children, ...props }) {
  return (
    <BillingContext.Provider value={props}>{children}</BillingContext.Provider>
  );
}

export function useBilling() {
  return useContext(BillingContext);
}
