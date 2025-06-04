import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import App from "./App.jsx";

setInterval(() => {
  const billingRoot = document.getElementById("billing-root");
  if (billingRoot && !billingRoot.hasChildNodes()) {
    createRoot(billingRoot).render(
      <StrictMode>
        <App />
      </StrictMode>
    );
  }
}, 100);
