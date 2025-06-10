import { BlockStack, Frame, Link, Loading, Page, Text } from "billing-polaris";
import { createContext, useState } from "react";
import { useBillingInformation } from "../hooks/useBillingInformation";
import LegacyPlanBanner from "../components/LegacyPlanBanner";
import PlanMismatchBanner from "../components/PlanMismatchBanner";
import { RemainingTrialDaysBanner } from "../components/RemainingTrialDaysBanner";
import CouponsCard from "../components/CouponsCard";
import AvailableBillingPlans from "../components/AvailableBillingPlans";
import { useBilling } from "../providers/BillingProvider";
import { Trans } from "react-i18next";

export const PlansAndCouponsContext = createContext();

const PlansAndCouponsProvider = ({ children }) => {
  const [activeCouponCode, setActiveCouponCode] = useState("");

  return (
    <PlansAndCouponsContext.Provider
      value={{ activeCouponCode, setActiveCouponCode }}
    >
      {children}
    </PlansAndCouponsContext.Provider>
  );
};

export default function BillingPage() {
  const { t, i18n, termsLink, avvLink, privacyLink } = useBilling();
  const { data: billingInfo, isLoading } = useBillingInformation();

  if (isLoading) {
    return (
      <Frame>
        <Loading />
      </Frame>
    );
  }

  return (
    <BlockStack gap="800">
      <PlansAndCouponsProvider>
        <BlockStack gap="0">
          <LegacyPlanBanner billingPlan={billingInfo?.billingPlan} />

          {billingInfo.planMismatchSince && (
            <PlanMismatchBanner billingPlan={billingInfo?.billingPlan} />
          )}

          {billingInfo?.remainingTrialDays > 0 && (
            <RemainingTrialDaysBanner
              remainingTrialDays={billingInfo?.remainingTrialDays}
            />
          )}
        </BlockStack>
        <BlockStack gap="400">
          <Text variant="headingLg" alignment="center">
            {t("billing.available_plans")}
          </Text>
          <AvailableBillingPlans />
          <BlockStack gap="50">
            <Text alignment="center">
              <Trans
                i18n={i18n}
                i18nKey="billing.accept_terms"
                components={{
                  a: <Link onClick={termsLink} />,
                  a2: <Link onClick={avvLink} />,
                  a3: <Link onClick={privacyLink} />,
                }}
              />
            </Text>
            {!billingInfo?.billingPlan && (
              <Text alignment="center">
                {t("billing.import_plan_not_available")}
              </Text>
            )}
          </BlockStack>
          <CouponsCard />
        </BlockStack>
      </PlansAndCouponsProvider>
    </BlockStack>
  );
}
