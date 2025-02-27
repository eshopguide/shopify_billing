# frozen_string_literal: true

# Mock ShopifyAPI namespace and classes for testing
module ShopifyAPI
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