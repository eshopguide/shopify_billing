import { useTranslation } from "react-i18next";
import {
  BlockStack,
  Button,
  ButtonGroup,
  Card,
  InlineGrid,
  SkeletonBodyText,
  Text,
} from "polaris-13";
import PlanCard from "./PlanCard";
import { useContext, useMemo, useState, useEffect } from "react";
import { PlansAndCouponsContext } from "../pages/Billing";
import { useBilling } from "../providers/BillingProvider";

const AvailableBillingPlans = () => {
  const { fetch } = useBilling();
  const { activeCouponCode } = useContext(PlansAndCouponsContext);
  const [plans, setPlans] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const { t } = useTranslation();
  const [interval, setInterval] = useState("ANNUAL");

  useEffect(() => {
    const fetchPlans = async () => {
      try {
        setIsLoading(true);
        const response = await fetch(
          `/shopify_billing/billing/plans?coupon_code=${activeCouponCode}`
        );
        const json = await response.json();
        setPlans(json);
      } catch (err) {
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };

    fetchPlans();
  }, [fetch, activeCouponCode]);

  const activePlanDetails = useMemo(() => {
    if (!plans?.recurring) return { monthly: null, annual: null };

    const monthlyPlan = plans.recurring.find(
      (plan) => plan.interval === "EVERY_30_DAYS" && plan.is_current_plan
    );
    const annualPlan = plans.recurring.find(
      (plan) => plan.interval === "ANNUAL" && plan.is_current_plan
    );

    return {
      monthly: monthlyPlan,
      annual: annualPlan,
    };
  }, [plans]);

  // Show the appropriate message based on the active plan
  const getMessage = () => {
    if (interval === "ANNUAL") {
      if (activePlanDetails.monthly) {
        if (activePlanDetails.monthly.short_name.includes("plus")) {
          return t("billing.extra_plan_info.monthly_plus_plan");
        } else {
          return t("billing.extra_plan_info.monthly_basic_plan");
        }
      }
    } else {
      if (activePlanDetails.annual) {
        if (activePlanDetails.annual.short_name.includes("plus")) {
          return t("billing.extra_plan_info.annual_plus_plan");
        } else {
          return t("billing.extra_plan_info.annual_basic_plan");
        }
      }
    }
    return null;
  };

  // Combine and sort plans to ensure Basic, Plus, Import order
  const allPlans = useMemo(() => {
    return (
      [...(plans?.recurring || []), ...(plans?.one_time || [])]
        .sort((a, b) => {
          // Always put import plan last
          if (a.short_name.toLowerCase() === "import") return 1;
          if (b.short_name.toLowerCase() === "import") return -1;

          // Sort other plans by price ascending
          return parseFloat(a.price) - parseFloat(b.price);
        })
        // Only show selected interval + import plan
        .filter(
          (plan) => plan.plan_type !== "recurring" || plan.interval === interval
        )
    );
  }, [plans, interval]);

  if (isLoading) {
    return (
      <InlineGrid columns={3} gap="400">
        {[1, 2, 3].map((idx) => (
          <Card key={idx}>
            <SkeletonBodyText lines={5} />
          </Card>
        ))}
      </InlineGrid>
    );
  }

  if (!plans) return;

  return (
    <BlockStack gap="400">
      <BlockStack align="center" inlineAlign="center">
        <ButtonGroup variant="segmented">
          <Button
            size="large"
            pressed={interval === "EVERY_30_DAYS"}
            onClick={() => setInterval("EVERY_30_DAYS")}
          >
            {t("billing.intervals.monthly")}
          </Button>
          <Button
            size="large"
            pressed={interval === "ANNUAL"}
            onClick={() => setInterval("ANNUAL")}
          >
            {t("billing.intervals.yearly")}
          </Button>
        </ButtonGroup>
      </BlockStack>
      <Text variant="bodyMd" alignment="center" color="info">
        {getMessage()}
      </Text>
      <InlineGrid columns={3} gap="400" align="end">
        {allPlans.map((plan) => (
          <PlanCard plan={plan} key={`billing-plan_${plan.id}`} />
        ))}
      </InlineGrid>
    </BlockStack>
  );
};

export default AvailableBillingPlans;
