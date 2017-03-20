module Blocktrail
  EXCEPTION_INVALID_CREDENTIALS = "Your credentials are incorrect."
  EXCEPTION_GENERIC_HTTP_ERROR = "An HTTP Error has occurred!"
  EXCEPTION_GENERIC_SERVER_ERROR = "An Server Error has occurred!"
  EXCEPTION_EMPTY_RESPONSE = "The HTTP Response was empty."
  EXCEPTION_UNKNOWN_ENDPOINT_SPECIFIC_ERROR = "The endpoint returned an unknown error."
  EXCEPTION_MISSING_ENDPOINT = "The endpoint you've tried to access does not exist. Check your URL."
  EXCEPTION_OBJECT_NOT_FOUND = "The object you've tried to access does not exist."

  module Exceptions
    def self.build_exception(error)
      case error.http_code
      when 400, 403
        data = JSON.parse(error.response)
        if data.present? && data['msg'] && data['code']
          Blocktrail::Exceptions::EndpointSpecificError.new(data['msg'], data['code'])
        else
          Blocktrail::Exceptions::UnknownEndpointSpecificError.new(Blocktrail::EXCEPTION_UNKNOWN_ENDPOINT_SPECIFIC_ERROR)
        end
      when 401
        Blocktrail::Exceptions::InvalidCredentials.new(Blocktrail::EXCEPTION_INVALID_CREDENTIALS, 401)
      when 404
        if error.response.body == 'Endpoint Not Found'
          Blocktrail::Exceptions::MissingEndpoint.new(Blocktrail::EXCEPTION_MISSING_ENDPOINT, 404)
        else
          Blocktrail::Exceptions::ObjectNotFound.new(Blocktrail::EXCEPTION_OBJECT_NOT_FOUND, 404)
        end
      when 500
        Blocktrail::Exceptions::GenericServerError.new(Blocktrail::EXCEPTION_GENERIC_SERVER_ERROR, error.http_code)
      else
        Blocktrail::Exceptions::GenericHTTPError.new(Blocktrail::EXCEPTION_GENERIC_HTTP_ERROR, error.http_code)
      end
    rescue
      Blocktrail::Exceptions::Exception.new(error.message)
    end

    class Exception < StandardError
      attr_reader :code

      def initialize(message, code = nil)
        @code = code
        super(message)
      end

      def message
        self.code.present? ? "[#{self.code}] #{self.message}" : self.message
      end
    end

    class InvalidFormat < Exception; end
    class EmptyResponse < Exception; end
    class EndpointSpecificError < Exception; end
    class UnknownEndpointSpecificError < Exception; end
    class InvalidCredentials < Exception; end
    class MissingEndpoint < Exception; end
    class ObjectNotFound < Exception; end
    class GenericHTTPError < Exception; end
    class GenericServerError < Exception; end
  end
end
