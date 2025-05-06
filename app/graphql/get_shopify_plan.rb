# frozen_string_literal: true

# https://shopify.dev/docs/api/admin-graphql/2024-07/objects/ShopPlan
class GetShopifyPlan
  include ShopifyGraphql::Query

  QUERY = <<~GRAPHQL
    query {
      shop {
        plan {
          displayName
          partnerDevelopment
          shopifyPlus
        }
      }
    }
  GRAPHQL

  def call
    response = execute(QUERY)
    response.data.shop.plan
  end
end
