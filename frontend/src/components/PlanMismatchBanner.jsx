import { Banner } from "polaris-13";
import { useTranslation } from "react-i18next";

export default function PlanMismatchBanner({ billingPlan }) {
  const { t } = useTranslation();

  return (
    <Banner title={t("billing.planMismatchBanner.title")} tone="warning">
      {t("billing.planMismatchBanner.text", {
        currentBillingPlanName: billingPlan.name,
      })}
    </Banner>
  );
}
