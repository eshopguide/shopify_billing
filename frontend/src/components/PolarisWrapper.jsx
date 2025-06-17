import { AppProvider } from "billing-polaris";
import ReactShadowRoot from "react-shadow-root";
import styles from "billing-polaris/build/esm/styles.css?raw";

export default function PolarisWrapper({ children, ...props }) {
  return (
    <div {...props}>
      <ReactShadowRoot>
        <style>
          {styles
            .replaceAll(":root", ":host")
            .replaceAll("html", ":host")
            .replaceAll("body", ":host")}
        </style>
        <AppProvider>{children}</AppProvider>
      </ReactShadowRoot>
    </div>
  );
}
