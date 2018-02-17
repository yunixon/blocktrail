require 'rest-client'
require 'digest/md5'
require 'json'
require 'blocktrail/exceptions'
require 'api-auth'

module Blocktrail
  class Client
    attr_accessor :api_key, :api_secret, :api_version, :testnet, :debug, :bitcoin_cash

    def initialize(api_key, api_secret, api_version = 'v1', testnet = false, debug = false, bitcoin_cash = true)
      @api_key = api_key
      @api_secret = api_secret
      @api_version = api_version
      @testnet = testnet
      @debug = debug
      @bitcoin_cash = bitcoin_cash
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

    def setup_webhook(url, identifier = nil)
      post("/webhook", { url: url, identifier: identifier })
    end

    def update_webhook(identifier, new_url = nil, new_identifier = nil)
      put("/webhook/#{identifier}", { url: new_url, identifier: new_identifier })
    end

    def delete_webhook(identifier)
      delete("/webhook/#{identifier}")
    end

    def subscribe_address_transactions(identifier, address, confirmations = 6)
      post("/webhook/#{identifier}/events", { event_type: 'address-transactions', address: address, confirmations: confirmations })
    end

    def subscribe_new_blocks(identifier)
      post("/webhook/#{identifier}/events", { event_type: 'block' })
    end

    def subscribe_transaction(identifier, transaction, confirmations = 6)
      post("/webhook/#{identifier}/events", { event_type: 'transaction', transaction: transaction, confirmations: confirmations })
    end

    def unsubscribe_address_transactions(identifier, address)
      delete("/webhook/#{identifier}/address-transactions/#{address}")
    end

    def unsubscribe_new_blocks(identifier)
      delete("/webhook/#{identifier}/block")
    end

    def unsubscribe_transaction(identifier, transaction)
      delete("/webhook/#{identifier}/transaction/#{transaction}")
    end

    def price
      get("/price")
    end

    def verify_message(message, address, signature)
      post("/verify_message", { message: message, address: address, signature: signature })
    end

    # Payments API

    def all_wallets(page = 1, limit = 20)
      get("/wallets", {}, params: { page: page, limit: limit })
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

    def send_transaction(identifier, raw_tx, paths, check_fee = false)
      post("/wallet/#{identifier}/send", { raw_transaction: raw_tx, paths: paths }, params: { check_fee: check_fee })
    end

    private

    def request(method, url, payload = {}, headers = {})
      url = "https://api.blocktrail.com/#{api_version}/#{testnet ? 't' : ''}#{bitcoin_cas ? bcc : btc}#{url}"

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
      response.empty? ? nil : JSON.parse(response, quirks_mode: true)
    rescue RestClient::ExceptionWithResponse => error
      raise Blocktrail::Exceptions.build_exception(error)
    end
  end
end
