require File.dirname(__FILE__) + '/test_helper'

class RiraTest < Test::Unit::TestCase
  JIRA_URL = "http://jira.lackac.hu"
  JIRA_USER = "rubi"
  JIRA_PASS = "j1r4b0t"

  context "A Rira Client" do
    should "be able to login with correct password" do
      rira = Rira(JIRA_URL + "/rpc/xmlrpc")
      assert_nothing_raised do
        rira = rira.login(JIRA_USER, JIRA_PASS)
      end
      assert rira.instance_variable_get('@token').length > 0
    end

    should "be created with the short URL (without /rpc/xmlrpc)" do
      rira = Rira(JIRA_URL)
      assert_nothing_raised { rira.login(JIRA_USER, JIRA_PASS) }
    end

    should "not get token with wrong password" do
      rira = Rira(JIRA_URL)
      assert_raise(Rira::RPCError) { rira.login("wrong", "authentication") }
    end
  end
end
