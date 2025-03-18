# frozen_string_literal: true

class GetAppInstallation
  include ShopifyGraphql::Query

  QUERY = <<~GRAPHQL
    query {
      appInstallation {
        activeSubscriptions {
          id
          currentPeriodEnd
          status
          createdAt
          test
        }
        oneTimePurchases(first: 250) {
          edges {
            node {
              id
              status
              createdAt
              test
            }
          }
        }
      }
    }
  GRAPHQL

  def call
    response = execute(QUERY)
    response.data&.appInstallation
  end
end