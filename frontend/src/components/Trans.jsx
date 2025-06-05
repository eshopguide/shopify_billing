import React from "react";
import reactStringReplace from "react-string-replace";

export const Trans = ({ i18nKey, t, components = {} }) => {
  const rawString = t(i18nKey);
  let result = rawString;
  let keyIndex = 0;

  Object.entries(components).forEach(([tag, component]) => {
    const regex = new RegExp(`<${tag}>(.*?)</${tag}>`, "g");

    result = reactStringReplace(result, regex, (match) => {
      const Comp = component.type || component;

      return (
        <Comp key={keyIndex++} {...Comp.props}>
          {match}
        </Comp>
      );
    });
  });

  return <>{result}</>;
};
