import { Banner } from "billing-polaris";
import { useBilling } from "../providers/BillingProvider";

export function RemainingTrialDaysBanner({ remainingTrialDays }) {
  const { t } = useBilling();

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
