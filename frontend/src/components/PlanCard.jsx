import { Trans } from "react-i18next";
import { useContext, useMemo, useState } from "react";
import {
  Badge,
  BlockStack,
  Button,
  Card,
  Icon,
  InlineStack,
  Text,
  Box,
} from "polaris-13";
import { MagicIcon, DiscountIcon } from "polaris-icons-v9";
import { PlansAndCouponsContext } from "../pages/Billing";
import { useBilling } from "../providers/BillingProvider";

export default function PlanCard({ plan }) {
  const { locale, showToast, fetch, t, i18n } = useBilling();
  const { activeCouponCode } = useContext(PlansAndCouponsContext);
  const [isLoading, setIsLoading] = useState(false);
  const features = useMemo(() => {
    return t(`billing.plan.${plan.short_name}.features`).split(".");
  }, [plan.short_name, t]);

  const choosePlan = async () => {
    try {
      setIsLoading(true);
      const response = await fetch("/shopify_billing/billing/charge", {
        method: "POST",
        body: JSON.stringify({
          plan_id: plan.id,
          coupon_code: activeCouponCode,
        }),
      });
      const data = await response.json();

      if (data.confirmation_url) {
        window.top.location.href = data.confirmation_url;
      } else {
        showToast(t("billing.plan.notifications.failure"), {
          isError: true,
        });
      }
    } catch (error) {
      console.error(error);
      showToast(t("billing.plan.notifications.failure"), {
        isError: true,
      });
    } finally {
      setIsLoading(false);
    }
  };

  const formatPrice = (price, currency) => {
    return new Intl.NumberFormat(locale, {
      style: "currency",
      currency: currency,
      minimumFractionDigits: 0,
      maximumFractionDigits: 2,
    }).format(parseFloat(price));
  };

  const isDisabled = useMemo(() => {
    if (plan.is_current_plan && plan.plan_type === "one_time") {
      return true;
    }

    // Disable the Import button if a plan is not yet active
    if (!plan.available) {
      return true;
    }

    // Disable if it's current plan and no active coupon
    if (plan.is_current_plan && !activeCouponCode) {
      return true;
    }

    if (plan.discount > 0 || plan.trial_days > plan.base_trial_days) {
      return false;
    }

    return plan.is_current_plan;
  }, [plan, activeCouponCode]);

  const buttonText = useMemo(() => {
    if (!plan.available) return t("billing.plan.buttonText.choosePlan");
    if (isDisabled) return t("billing.plan.buttonText.current");

    if (plan.short_name.toLowerCase() === "import") {
      return t("billing.plan.buttonText.oneTimePayment");
    }

    let text =
      plan.trial_days > 0 && !plan.development_plan
        ? t("billing.plan.buttonText.choosePlanWithTrialDays", {
            trialDays: plan.trial_days,
          })
        : t("billing.plan.buttonText.choosePlan");

    if (plan.is_current_plan)
      text += ` (${t("billing.plan.buttonText.current")})`;

    return text;
  }, [plan, t, isDisabled]);

  const cardTitleText = useMemo(() => {
    return plan.available ? plan.name : `${plan.name}*`;
  }, [plan.name, plan.available]);

  const cardMarkup = (
    <BlockStack gap="400" align="space-between">
      <BlockStack gap="400" align="space-between">
        <InlineStack gap="200" align="space-between" blockAlign="center">
          <Text variant="headingLg" alignment="start">
            {cardTitleText}
          </Text>
          {plan.recommended && (
            <Badge tone="magic" icon={MagicIcon}>
              {t("billing.plan.recommended")}
            </Badge>
          )}
        </InlineStack>

        <InlineStack align="start" blockAlign="baseline" gap="200">
          {!plan.development_plan && (
            <Text variant="heading2xl">
              {plan.interval === "ANNUAL"
                ? formatPrice(plan.price / 12, plan.currency)
                : formatPrice(plan.price, plan.currency)}
            </Text>
          )}
          {plan.development_plan && (
            <Text variant="heading2xl">{formatPrice(0, plan.currency)}</Text>
          )}
          <Text tone="subdued">
            {t(`billing.plan.${plan.plan_type}.frequency`)}
          </Text>
          {plan.discount > 0 && (
            <InlineStack align="start" blockAlign="baseline" gap="200">
              <Badge tone="success" icon={DiscountIcon}>
                {t("billing.plan.discount", {
                  discount: parseInt(plan.discount, 10),
                })}
              </Badge>
            </InlineStack>
          )}
        </InlineStack>

        <Box minHeight={"1.5em"}>
          <BlockStack gap="100">
            {plan.interval === "ANNUAL" && plan.price > 1 && (
              <Text fontWeight="bold">
                {t("billing.plan.pricePerYear", {
                  amount: formatPrice(plan.price, plan.currency),
                })}
              </Text>
            )}
            {plan.short_name.toLowerCase() === "import" ? (
              <Text alignment="start" fontWeight="medium">
                {t("billing.plan.one_time.unlimited_use")}
              </Text>
            ) : (
              plan.trial_days > 0 &&
              !(plan.is_current_plan && !activeCouponCode) && (
                <>
                  {plan.trial_days > plan.base_trial_days ? (
                    <Text
                      alignment="start"
                      fontWeight="semibold"
                      tone="success"
                    >
                      <Trans
                        i18n={i18n}
                        i18nKey="billing.plan.trialDaysDiscounted"
                        values={{
                          trialDays: plan.trial_days,
                          baseTrialDays: plan.base_trial_days,
                        }}
                        components={{ s: <Text as="s" /> }}
                      />
                    </Text>
                  ) : (
                    <Text alignment="start" fontWeight="medium">
                      {t("billing.plan.trialDays", {
                        trialDays: plan.trial_days,
                      })}
                    </Text>
                  )}
                </>
              )
            )}
          </BlockStack>
        </Box>

        <BlockStack gap="200">
          {features.map((feature, index) => (
            <InlineStack
              gap="200"
              align="start"
              blockAlign="center"
              key={`plan_features_${index}`}
              wrap={false}
            >
              <div>
                <Icon source={CheckIcon} tone="success" />
              </div>
              <Text alignment="start">{feature}</Text>
            </InlineStack>
          ))}
        </BlockStack>
      </BlockStack>
      <InlineStack gap="200">
        <Button
          variant={plan.is_current_plan ? "primary" : "primary"}
          size="large"
          onClick={choosePlan}
          loading={isLoading}
          disabled={isDisabled}
        >
          {buttonText}
        </Button>
      </InlineStack>
    </BlockStack>
  );

  return (
    <Card background={plan.is_current_plan ? "bg-surface-active" : undefined}>
      {cardMarkup}
    </Card>
  );
}

// TODO: Use icon from @shopify/polaris-icons after upgrade
const CheckIcon = () => {
  return (
    <svg
      viewBox="0 0 20 20"
      className="Icon_Icon__uZZKy"
      style={{ width: "20px", height: "20px" }}
    >
      <path
        fillRule="evenodd"
        d="M15.78 5.97a.75.75 0 0 1 0 1.06l-6.5 6.5a.75.75 0 0 1-1.06 0l-3.25-3.25a.75.75 0 1 1 1.06-1.06l2.72 2.72 5.97-5.97a.75.75 0 0 1 1.06 0Z"
      ></path>
    </svg>
  );
};
