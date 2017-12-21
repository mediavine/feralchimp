require "feralchimp/version"
require "faraday"
require "json"

class Feralchimp
  [:KeyError, :MailchimpError].each do |o|
    const_set o, Class.new(StandardError)
  end

  @raise = false
  @exportar = false
  @api_key = ENV["MAILCHIMP_API_KEY"]
  @timeout = 5

  def initialize(opts = {})
    @raw_api_key = opts[:api_key] || self.class.api_key
    @api_key = parse_mailchimp_key(@raw_api_key)
  end

  def method_missing(method, *args)
    if method == :export
      self.class.exportar = true
      if args.count > 0
        raise ArgumentError, "#{args.count} for 0"
      end

      # Ohrly?!?!
      return self
    else
      raise_or_return send_to_mailchimp(method, *args)
    end
  end

  protected
  def send_to_mailchimp(method, bananas = {}, export = self.class.exportar)
    path = api_path(mailchimp_method(method), export)
    self.class.exportar = false

    http = mailchimp_http(@api_key[:region], export)
    bananas = bananas.merge(:apikey => @api_key[:secret]).to_json
    http.post(path, bananas).body
  end

  protected
  def mailchimp_http(zone, export)
    Faraday.new(:url => api_url(zone)) do |h|
      h.response(export ? :mailchimp_export : :mailchimp)
      h.headers[:content_type] = "application/json"
      h.options[:timeout] = self.class.timeout
      h.adapter(Faraday.default_adapter)
      h.options[:open_timeout] = self.class.timeout
    end
  end

  protected
  def parse_mailchimp_key(api_key)
  api_key = api_key.to_s
    if api_key && ! api_key.empty? && api_key =~ %r![a-z0-9]+-[a-z]{2}\d{1}!
      api_key = api_key.to_s.split("-")
      {
        :region => api_key.last,
        :secret => api_key.first
      }
    else
      raise KeyError, "Invalid key#{": #{api_key}" unless api_key.empty?}."
    end
  end

  protected
  def api_path(method, export = false)
    export ? "/export/1.0/#{method}/" : "/2.0/#{method}.json"
  end

  protected
  def api_url(zone)
    URI.parse("https://#{zone}.api.mailchimp.com")
  end

  protected
  def raise_or_return(rtn)
    if rtn.is_a?(Hash) && rtn.has_key?("error")
      raise MailchimpError, rtn["error"]
    end

  rtn
  end

  protected
  def mailchimp_method(method)
    method = method.to_s.split("_")
    "#{method[0]}#{("/" + method[1..-1].join("-")) if method.count > 1}"
  end

  class << self
    attr_accessor :exportar, :timeout, :api_key

    def method_missing(method, *args)
      if method != :to_ary
        new.send(method, *args)
      else
        super
      end
    end
  end

  module Response
    class JSON < Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete do |e|
          e[:raw_body] = e[:body]
          e[:body] =
            ::JSON.parse("[" + e[:raw_body].to_s + "]").first
        end
      end
    end

    class JSONExport < Faraday::Middleware
      def call(environment)
        @app.call(environment).on_complete do |e|
          e[:raw_body] = e[:body]

          body = e[:body].each_line.to_a
          keys = ::JSON.parse(body.shift)
          e[:body] = body.inject([]) do |a, k|
            a.push(Hash[keys.zip(::JSON.parse(k))])
          end
        end
      end
    end
  end
end

{ :mailchimp => :JSON, :mailchimp_export => :JSONExport }.each do |m, o|
  o = Feralchimp::Response.const_get(o)
  Faraday.register_middleware(:response, m => proc { o })
end
