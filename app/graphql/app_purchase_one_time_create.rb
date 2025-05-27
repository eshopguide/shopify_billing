# frozen_string_literal: true

class AppPurchaseOneTimeCreate
  include ShopifyGraphql::Mutation

  QUERY = <<~GRAPHQL
    mutation AppPurchaseOneTimeCreate($name: String!, $price: MoneyInput!, $returnUrl: URL!, $test: Boolean!) {
      appPurchaseOneTimeCreate(name: $name, price: $price, returnUrl: $returnUrl, test: $test) {
        userErrors {
          field
          message
        }
        appPurchaseOneTime {
          id
        }
        confirmationUrl
      }
    }
  GRAPHQL

  def call(variables:)
    response = execute(QUERY, **variables)
    response.data = response.data.appPurchaseOneTimeCreate

    handle_user_errors(response.data)
    response
  end
end
