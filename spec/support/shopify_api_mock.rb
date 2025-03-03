# frozen_string_literal: true

# Mock ShopifyAPI namespace and classes for testing
module ShopifyAPI
  module Auth
    def self.embedded_app_url(host)
      "https://admin.shopify.com/apps/my-app"
    end

    class Session
      attr_reader :shop, :access_token, :scope

      def self.find_by_shop(shop_domain)
        new(shop: shop_domain, access_token: "test_token", scope: "read_products,write_products")
      end

      def initialize(shop:, access_token:, scope:)
        @shop = shop
        @access_token = access_token
        @scope = scope
      end
    end
  end

  class RecurringApplicationCharge
    def self.find(id:)
      new
    end

    def initialize(attributes = {})
      attributes.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def status
      @status || 'active'
    end

    def id
      @id || '12345'
    end

    def trial_ends_on
      @trial_ends_on || (Date.today + 14)
    end

    def price
      @price || 19.99
    end

    def save!
      true
    end
  end

  class ApplicationCharge
    def self.find(id:)
      new
    end

    def initialize(attributes = {})
      attributes.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def status
      @status || 'active'
    end

    def id
      @id || '12345'
    end

    def price
      @price || 19.99
    end

    def save!
      true
    end
  end
end