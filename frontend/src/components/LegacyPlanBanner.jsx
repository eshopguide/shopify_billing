import { Banner } from "polaris-13";
import { useTranslation } from "react-i18next";

export default function LegacyPlanBanner({ billingPlan }) {
  const { t } = useTranslation();

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
