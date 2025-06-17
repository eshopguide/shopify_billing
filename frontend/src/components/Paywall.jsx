import { Banner } from "billing-polaris";
import { useBillingInformation } from "../hooks/useBillingInformation";
import { useBilling } from "../providers/BillingProvider";
import PolarisWrapper from "./PolarisWrapper";

export default function Paywall({ feature, children }) {
  const { t, goToBilling } = useBilling();
  const { data, isLoading } = useBillingInformation();
  const { features } = data?.billingPlan || {};

  if (isLoading) return null;

  // If feature is available in the shops billing plan, just show the children (without paywall)
  if (features && features.includes(feature)) {
    return children;
  }

  return (
    <div style={{ position: "relative" }}>
      {children}
      <PolarisWrapper
        style={{
          position: "absolute",
          top: 0,
          right: 0,
          bottom: 0,
          left: 0,
          backgroundColor: "transparent",
          backdropFilter: "blur(2px)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          paddingLeft: 40,
          paddingRight: 40,
          zIndex: 1000,
        }}
      >
        <Banner
          tone="warning"
          title={t("billing.paywall.title")}
          action={{
            content: t("billing.paywall.buttonLabel"),
            onAction: goToBilling,
          }}
        >
          {t("billing.paywall.text")}
        </Banner>
      </PolarisWrapper>
    </div>
  );
}
