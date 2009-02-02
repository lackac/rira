require 'xmlrpc/client'
require 'ostruct'

def Rira(url)
  unless url =~ %r{/rpc/xmlrpc$}
    url += '/' unless url[-1] == ?/
    url += 'rpc/xmlrpc'
  end
  Rira::Client.new(url)
end

module Rira
  class RPCError < StandardError
    def initialize(fault_exception)
      super("#{fault_exception.faultCode}: #{fault_exception.faultString}")
    end
  end

  class Client
    def initialize(url)
      @url = url
    end

    def login(username, password)
      Rira::Base.new(@url, username, password)
    end
  end

  class Base
    MAPPINGS = {
      :get_projects => 'getProjectsNoSchemes'
    }

    def initialize(url, username, password, options = {})
      @url, @username, @password = url, username, password
      @token = xmlrpc_client.call("jira1.login", @username, @password)
    rescue XMLRPC::FaultException => e
      raise RPCError.new(e)
    end

    def method_missing(method, *args)
      method = MAPPINGS[method] || method.to_s.gsub(/_(.)/) {$1.upcase}
      case result = xmlrpc_client.call("jira1.#{method}", @token, *args)
      when Hash
        OpenStruct.new(result)
      when Array
        result.map {|item| item.is_a?(Hash) ? OpenStruct.new(item) : item}
      else
        result
      end
    rescue XMLRPC::FaultException => e
      raise RPCError.new(e)
    end

    def xmlrpc_client
      XMLRPC::Client.new2(@url)
    end
  end
end
