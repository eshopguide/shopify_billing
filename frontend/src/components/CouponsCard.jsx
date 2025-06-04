import React, { useContext, useState } from "react";
import {
  Button,
  Text,
  BlockStack,
  TextField,
  InlineStack,
  Card,
} from "polaris-13";
import { PlansAndCouponsContext } from "../pages/Billing";
import { useBilling } from "../providers/BillingProvider";

export default function CouponsCard() {
  const { setActiveCouponCode } = useContext(PlansAndCouponsContext);
  const [couponCode, setCouponCode] = useState("");
  const { showToast, fetch, t } = useBilling();

  const checkCoupon = async () => {
    const response = await fetch("/shopify_billing/billing/check_coupon", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        coupon_code: couponCode,
      }),
    });

    if (response.ok) {
      showToast(t("billing.coupon.success"));
      setActiveCouponCode(couponCode);
    } else {
      showToast(t("billing.coupon.error"), {
        isError: true,
      });
    }

    setCouponCode("");

    return response.json();
  };

  return (
    <Card>
      <BlockStack gap="400">
        <Text variant="headingMd">{t("billing.coupon.title")}</Text>
        <Text>{t("billing.coupon.description")}</Text>
        <InlineStack gap="200">
          <TextField
            placeholder={t("billing.coupon.placeholder")}
            monospaced={true}
            label=""
            value={couponCode}
            onChange={setCouponCode}
            autoComplete="off"
          />
          <Button onClick={checkCoupon} disabled={!couponCode}>
            {t("billing.coupon.button")}
          </Button>
        </InlineStack>
      </BlockStack>
    </Card>
  );
}
