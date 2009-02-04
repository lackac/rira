require 'xmlrpc/client'
require 'ostruct'

require File.join(File.dirname(__FILE__), 'rira', 'model')
require File.join(File.dirname(__FILE__), 'rira', 'base')

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
end
