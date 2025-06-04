import { Banner } from "polaris-13";
import { useTranslation } from "react-i18next";

export function RemainingTrialDaysBanner({ remainingTrialDays }) {
  const { t } = useTranslation();

  if (remainingTrialDays > 0) {
    return (
      <Banner>
        {t("billing.remainingTrialDays", {
          days: remainingTrialDays,
        })}
      </Banner>
    );
  }
}
