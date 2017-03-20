require 'rest-client'
require 'digest/md5'
require 'json'
require 'blocktrail/exceptions'
require 'api-auth'

module Blocktrail
  class Client
    attr_accessor :api_key, :api_secret, :api_version, :testnet, :debug

    def initialize(api_key, api_secret, api_version = 'v1', testnet = false, debug = false)
      @api_key = api_key
      @api_secret = api_secret
      @api_version = api_version
      @testnet = testnet
      @debug = debug
    end

    def api_key
      @api_key || ENV['API_KEY']
    end

    def api_secret
      @api_secret ||= ENV['API_SECRET']
    end

    def default_headers
      {
        'Content-Type' => 'application/json',
        'User-Agent': "#{Blocktrail::SDK_USER_AGENT}/#{Blocktrail::VERSION}",
        'Date': Time.now.utc.iso8601
      }
    end

    def default_params
      {
        'api_key': api_key
      }
    end

    def get(*args)
      request(:get, *args)
    end

    def post(*args)
      request(:post, *args)
    end

    def put(*args)
      request(:put, *args)
    end

    def delete(*args)
      request(:delete, *args)
    end

    def head(*args)
      request(:head, *args)
    end

    def options(*args)
      request(:options, *args)
    end

    # Data API

    def address(address)
      get("/address/#{address}")
    end

    def address_transactions(address, page = 1, limit = 20, sort_dir = 'asc')
      get("/address/#{address}/transactions", {}, params: { page: page, limit: limit, sort_dir: sort_dir })
    end

    def address_unconfirmed_transactions(address, page = 1, limit = 20, sort_dir = 'asc')
      get("/address/#{address}/unconfirmed-transactions", {}, params: { page: page, limit: limit, sort_dir: sort_dir })
    end

    def address_unspent_outputs(address, page = 1, limit = 20, sort_dir = 'asc')
      get("/address/#{address}/unspent-outputs", {}, params: { page: page, limit: limit, sort_dir: sort_dir })
    end

    def verify_address(address, signature)
      post("/address/#{address}/verify", { signature: signature })
    end

    def all_blocks(page = 1, limit = 20, sort_dir = 'asc')
      get("/all-blocks", {}, params: { page: page, limit: limit, sort_dir: sort_dir })
    end

    def block_latest
      get("/block/latest")
    end

    def block(block)
      get("/block/#{block}")
    end

    def block_transactions(block, page = 1, limit = 20, sort_dir = 'asc')
      get("/block/#{block}/transactions", {}, params: { page: page, limit: limit, sort_dir: sort_dir })
    end

    def transaction(txhash)
      get("/transaction/#{txhash}")
    end

    def all_webhooks(page = 1, limit = 20)
      get("/webhooks", {}, params: { page: page, limit: limit })
    end

    def webhook(identifier)
      get("/webhook/#{identifier}")
    end

    def webhook_events(identifier, page = 1, limit = 20)
      get("/webhook/#{identifier}/events", {}, params: { page: page, limit: limit })
    end

    def price
      get("/price")
    end

    # Payments API

    def all_wallets(page = 1, limit = 20)
      get("/wallets", nil, {}, params: { page: page, limit: limit })
    end

    def get_wallet(identifier)
      get("/wallet/#{identifier}")
    end

    def get_wallet_balance(identifier)
      get("/wallet/#{identifier}/balance")
    end

    def wallet_discovery(identifier, gap = 200)
      get("/wallet/#{identifier}/discovery", {}, params: { gap: gap })
    end

    def get_new_derivation(identifier, path)
      post("/wallet/#{identifier}/path", { path: path })
    end

    private

    def request(method, url, payload = {}, headers = {})
      url = "https://api.blocktrail.com/#{api_version}/#{testnet ? 't' : ''}btc#{url}"

      headers['Content-MD5'] = if payload.empty?
        Digest::MD5.hexdigest('') # needs url here
      else
        Digest::MD5.hexdigest(payload.to_json)
      end

      headers && headers[:params] ? headers[:params].merge!(default_params) : headers[:params] = default_params
      headers = default_headers.merge(headers)
      payload = payload.to_json
      if debug
        puts 'URL: ' + url.inspect
        puts 'Headers: ' + headers.inspect
        puts 'Payload: ' + payload.inspect
      end

      request = RestClient::Request.new(method: method, url: url, payload: payload, headers: headers)
      signed_request = ApiAuth.sign!(request, api_key, api_secret, digest: 'sha256')
      response = signed_request.execute

      if debug
        puts 'Request: ' + response.request.inspect
        puts 'Status code: ' + response.code.inspect
        puts 'Headers: ' + response.headers.inspect
        puts 'Content: ' + response.body.inspect
      end
      response.empty? ? nil : JSON.parse(response)
    rescue RestClient::ExceptionWithResponse => error
      raise Blocktrail::Exceptions.build_exception(error)
    end
  end
end
