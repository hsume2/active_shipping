module ActiveMerchant #:nodoc:
  module Shipping #:nodoc:

    class RateEstimate
      attr_reader :origin         # Location objects
      attr_reader :destination
      attr_reader :package_rates  # array of hashes in the form of {:package => <Package>, :rate => 500}
      attr_reader :carrier        # Carrier.name ('USPS', 'FedEx', etc.)
      attr_reader :service_name   # name of service ("First Class Ground", etc.)
      attr_reader :service_code
      attr_reader :currency       # 'USD', 'CAD', etc.
                                  # http://en.wikipedia.org/wiki/ISO_4217
      attr_reader :delivery_date  # Usually only available for express shipments

      attr_reader :total_billing_weight
      attr_reader :total_base_charge
      attr_reader :total_freight_discounts
      attr_reader :total_net_freight
      attr_reader :total_surcharges
      attr_reader :total_net_fedex_charge
      attr_reader :total_taxes
      attr_reader :total_rebates
      attr_reader :package_estimates

      def initialize(origin, destination, carrier, service_name, options={})
        @origin, @destination, @carrier, @service_name = origin, destination, carrier, service_name
        @service_code = options[:service_code]
        if options[:package_rates]
          @package_rates = options[:package_rates].map {|p| p.update({:rate => Package.cents_from(p[:rate])}) }
        else
          @package_rates = Array(options[:packages]).map {|p| {:package => p}}
        end
        @total_price = Package.cents_from(options[:total_price])
        @currency = options[:currency]
        @delivery_date = options[:delivery_date]

        @total_billing_weight    = Package.cents_from(options[:total_billing_weight])
        @total_base_charge       = Package.cents_from(options[:total_base_charge])
        @total_freight_discounts = Package.cents_from(options[:total_freight_discounts])
        @total_net_freight       = Package.cents_from(options[:total_net_freight])
        @total_surcharges        = Package.cents_from(options[:total_surcharges])
        @total_net_fedex_charge  = Package.cents_from(options[:total_net_fedex_charge])
        @total_taxes             = Package.cents_from(options[:total_taxes])
        @total_rebates           = Package.cents_from(options[:total_rebates])
        @package_estimates       = options[:package_estimates]
      end

      def total_price
        begin
          @total_price || @package_rates.sum {|p| p[:rate]}
        rescue NoMethodError
          raise ArgumentError.new("RateEstimate must have a total_price set, or have a full set of valid package rates.")
        end
      end
      alias_method :price, :total_price

      def add(package,rate=nil)
        cents = Package.cents_from(rate)
        raise ArgumentError.new("New packages must have valid rate information since this RateEstimate has no total_price set.") if cents.nil? and total_price.nil?
        @package_rates << {:package => package, :rate => cents}
        self
      end

      def packages
        package_rates.map {|p| p[:package]}
      end

      def package_count
        package_rates.length
      end

    end
  end
end
