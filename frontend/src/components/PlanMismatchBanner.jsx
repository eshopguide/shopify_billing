import { Banner } from "billing-polaris";
import { useBilling } from "../providers/BillingProvider";

export default function PlanMismatchBanner({ billingPlan }) {
  const { t } = useBilling();

  if (!billingPlan) {
    return null;
  }

  return (
    <Banner title={t("billing.planMismatchBanner.title")} tone="warning">
      {t("billing.planMismatchBanner.text", {
        currentBillingPlanName: billingPlan.name,
      })}
    </Banner>
  );
}
