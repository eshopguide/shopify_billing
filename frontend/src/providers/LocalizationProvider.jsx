import { useEffect } from "react";
import i18next from "i18next";
import { initReactI18next, I18nextProvider } from "react-i18next";
import de from "../../locales/de.json";
import en from "../../locales/en.json";
import { useBilling } from "./BillingProvider";

const defaultLocale = "en";
const resources = {
  en: {
    translation: en,
  },
  de: {
    translation: de,
  },
};

i18next.use(initReactI18next).init({
  resources,
  lng: defaultLocale,
  fallbackLng: defaultLocale,
  interpolation: {
    escapeValue: false,
  },
});

export function LocalizationProvider({ children }) {
  const { locale } = useBilling();

  useEffect(() => {
    if (locale) {
      // TODO:
      i18next.changeLanguage(locale);
    }
  }, [locale]);

  return <I18nextProvider i18n={i18next}>{children}</I18nextProvider>;
}

export function useTranslation() {
  return {
    t: i18next.t,
  };
}
