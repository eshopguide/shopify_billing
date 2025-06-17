import { AppProvider } from "billing-polaris";
import ReactShadowRoot from "react-shadow-root";
import styles from "billing-polaris/build/esm/styles.css?raw";
import { useMemo } from "react";

export default function PolarisWrapper({ children, ...props }) {
  const polarisStyles = useMemo(() => {
    return styles
      .replaceAll(":root", ":host")
      .replaceAll("html", ":host")
      .replaceAll("body", ":host");
  }, []);

  return (
    <div {...props}>
      <ReactShadowRoot>
        <style>{polarisStyles}</style>
        <AppProvider>{children}</AppProvider>
      </ReactShadowRoot>
    </div>
  );
}
