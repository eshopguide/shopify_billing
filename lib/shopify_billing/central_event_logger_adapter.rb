# frozen_string_literal: true

module ShopifyBilling
  class CentralEventLoggerAdapter
    def self.log_event(params)
      CentralEventLogger.log_event(
        event_name: params.fetch(:event_name),
        event_type: params.fetch(:event_type),
        customer_myshopify_domain: params.fetch(:customer_myshopify_domain),
        customer_info: params.fetch(:customer_info, {}),
        event_value: params.fetch(:event_value),
        payload: params.fetch(:payload),
        timestamp: params.fetch(:timestamp),
        external_id: params[:external_id]
      )
    end
  end
end