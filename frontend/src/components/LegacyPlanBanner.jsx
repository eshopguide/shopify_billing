import { Banner } from "billing-polaris";
import { useBilling } from "../providers/BillingProvider";

export default function LegacyPlanBanner({ billingPlan }) {
  const { t } = useBilling();

  if (!billingPlan || !billingPlan.is_legacy) {
    return null;
  }

  return (
    <Banner title={t("billing.legacyPlanBanner.title")} tone="info">
      {t("billing.legacyPlanBanner.text", {
        planName: billingPlan.name,
      })}
    </Banner>
  );
}
