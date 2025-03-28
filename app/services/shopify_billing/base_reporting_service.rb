# frozen_string_literal: true

module ShopifyBilling
  class BaseReportingService < ShopifyBilling::ApplicationService
    def verification_token
      Digest::SHA1.hexdigest([@shop.id, @billing_plan.id].join('|'))
    end

    protected

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def report_event(params)
      ShopifyBilling.event_reporter.log_event(
        event_name: params.fetch(:event_name),
        event_type: params.fetch(:event_type),
        customer_myshopify_domain: params.fetch(:customer_myshopify_domain),
        customer_info: params.fetch(:customer_info, {}),
        event_value: params.fetch(:event_value),
        payload: params.fetch(:payload),
        timestamp: params.fetch(:timestamp, Time.zone.now),
        external_id: params[:external_id]
      )
    rescue StandardError => e
      Rails.error.report(e, handled: false, context: {
                           event_name: params[:event_name],
                           user_id: params[:customer_myshopify_domain],
                           event_type: params[:event_type],
                           error_message: e.message
                         })
      Rails.logger.error("Failed to report #{params[:event_name]} event: #{e.message}")
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
  end
end
