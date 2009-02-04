module Rira
  class Base
    def initialize(url, username, password, options = {})
      @url, @username, @password = url, username, password
      @token = xmlrpc_client.call("jira1.login", @username, @password)
    rescue XMLRPC::FaultException => e
      raise RPCError.new(e)
    end

    def xmlrpc_client
      XMLRPC::Client.new2(@url)
    end

    MAPPINGS = {
      :projects => ['project', "getProjectsNoSchemes", "getProjects"],
      :projects_no_schemes => ['project', "getProjectsNoSchemes", "getProjects"],
      :components => ['component', "getComponents"],
      :versions => ['version', "getVersions"],
      :issue_types => ['issue_type', "getIssueTypes"],
      :issue_types_for_project => ['issue_type', "getIssueTypesForProject"],
      :sub_task_issue_types => ['issue_type', "getSubTaskIssueTypes"],
      :sub_task_issue_types_for_project => ['issue_type', "getSubTaskIssueTypesForProject"],
      :create_issue => ['issue', "createIssue"],
      :update_issue => ['issue', "updateIssue"],
      :issue => ['issue', "getIssue"],
      :issues_from_filter => ['issue', "getIssuesFromFilter"],
      :search => ['issue', "getIssuesFromTextSearch"],
      :search_with_project => ['issue', "getIssuesFromTextSearchWithProject"],
      :add_comment => [nil, "addComment"],
      :comments => ['comment', "getComments"],
      :priorities => ['priority', "getPriorities"],
      :resolutions => ['resolution', "getResolutions"],
      :statuses => ['status', "getStatuses"],
      :favourite_filters => ['filter', "getFavouriteFilters"],
      :saved_filters => ['filter', "getSavedFilters"],
      :server_info => ['server_info', "getServerInfo"],
      :user => ['user', "getUser"],
      :logout => [nil, "logout"],
    }

    def method_missing(method, *args)
      model, *methods = MAPPINGS[method]
      
      super(method, *args) if methods.empty?

      begin
        case result = xmlrpc_client.call("jira1.#{methods.shift}", @token, *args)
        when Hash
          model_or_struct(model, result)
        when Array
          result.map do |item|
            if item.is_a?(Hash)
              model_or_struct(model, item)
            else
              item
            end
          end
        else
          result
        end
      rescue XMLRPC::FaultException => e
        retry unless methods.empty?
        raise RPCError.new(e)
      end
    end

    private

      def model_or_struct(model, result)
        if model
          Model.new(self, model, result)
        else
          OpenStruct.new(result)
        end
      end
  end
end
