require "httparty"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/enumerable"
require "active_support/core_ext/big_decimal"
require 'active_support/core_ext/hash/indifferent_access'

# override HTTParty's json parser to return a HashWithIndifferentAccess

class BetterJsonParser < HTTParty::Parser
  def json
    result = super
    if result.is_a?(Hash)
      result = HashWithIndifferentAccess.new(result)
    end
    result
  end
end

class Oanda
  def self.config
    OandaExchange::Config.get
  end

  include HTTParty
  debug_output $stdout
  base_uri config[:base_url]
  format :json
  parser BetterJsonParser

  def self.exchange(base_currency, options = {})
    raise Exception.new("no base currency specified")   if base_currency.blank?
    raise Exception.new("no quote currency specified")  if options[:to].blank?
    options[:amount] = (options[:amount] || 1).to_d
    instrument = find_instrument(base_currency, options[:to])
    if instrument.nil?
      instrument = find_instrument(options[:to], base_currency)
      inverse = true
    else
      inverse = false
    end
    if instrument.nil?
      raise ArgumentError, 'failed to find OANDA instrument to fetch price'
    end
    log.debug "inverse = #{inverse}"
    rate = price(instrument)[:bid].to_d
    rate = inverse ? 1.to_d/rate : rate
    result = options[:amount]*rate
  end

  def self.instruments
    if @instruments.nil?
      @supported_currencies ||= Currency.pluck(:code)

      response = get('/instruments', headers: headers, query: {accountId: account_id}) if @instruments.nil?
      @instruments ||=
        response[:instruments].select{ |instrument| 
          instrument[:instrument].split('_').all?{|code| @supported_currencies.include?(code)}
        }.map{ |instrument| instrument[:instrument] }
    else
      @instruments
    end
  end

  def self.price(instrument)
    response = get '/prices', headers: headers, query: {instruments: instrument}
    log.debug "price = #{response[:prices]}"
    response[:prices].present? ? response[:prices].first : nil
  end

  private

  def self.find_instrument(currency_from, currency_to)
    instruments.find{ |instrument| "#{currency_from}_#{currency_to}" == instrument }
  end

  def self.headers
    basic_headers.merge(auth_header)
  end

  def self.basic_headers
    @basic_headers ||= {'Content-Type' => 'application/json',
                        'Accept' => 'application/json',
                        'Connection' => 'keep-alive',
                        'Accept-Encoding' => 'gzip, deflate'
                         }
  end

  def self.auth_header
    @auth_header ||= {'Authorization' => "Bearer #{client_id}"}
  end

  def self.account_id
    @account_id ||= config[:account_id]
  end
  
  def self.client_id
    @client_id ||= config[:client_id]
  end

  def self.log
    OandaExchange::Config.logger
  end

end