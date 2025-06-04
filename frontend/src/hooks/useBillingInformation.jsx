import { useQuery } from "@tanstack/react-query";
import { useBilling } from "../providers/BillingProvider";

export const useBillingInformation = () => {
  const { fetch } = useBilling();

  return useQuery({
    queryKey: ["shopify_billing"],
    queryFn: () => fetch("/shopify_billing").then((res) => res.json()),
  });
};
