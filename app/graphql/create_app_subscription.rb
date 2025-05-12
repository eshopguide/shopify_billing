# frozen_string_literal: true

class CreateAppSubscription
  include ShopifyGraphql::Mutation

  QUERY = <<~GRAPHQL
    mutation AppSubscriptionCreate($name: String!, $lineItems: [AppSubscriptionLineItemInput!]!, $returnUrl: URL!, $trialDays: Int, $test: Boolean) {
      appSubscriptionCreate(name: $name, returnUrl: $returnUrl, lineItems: $lineItems, trialDays: $trialDays, test: $test) {
        userErrors {
          field
          message
        }
        appSubscription {
          id
        }
        confirmationUrl
      }
    }
  GRAPHQL

  def call(variables:)
    response = execute(QUERY, **variables)
    response.data = response.data.appSubscriptionCreate

    handle_user_errors(response.data)
    response
  end
end
