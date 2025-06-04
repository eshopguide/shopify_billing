import { useState, useEffect } from "react";
import { useBilling } from "../providers/BillingProvider";

export const useBillingInformation = () => {
  const { fetch } = useBilling();
  const [data, setData] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(
    () => {
      const fetchData = async () => {
        try {
          setIsLoading(true);
          const response = await fetch("/shopify_billing");
          const json = await response.json();
          setData(json);
        } catch (err) {
          setError(err);
        } finally {
          setIsLoading(false);
        }
      };

      fetchData();
    },
    [
      /*fetch*/
    ]
  );

  return { data, isLoading, error };
};
