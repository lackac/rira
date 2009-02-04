module Rira
  class Model
    ASSOCIATIONS = {
      "add_comment"   => ["issue", "key"],
      "comments"      => ["issue", "key"],
      "components"    => ["project", "key"],
      "issues"        => ["filter", "id",
                          "issues_from_filter"],
      "search"        => ["project", "keys",
                          "search_with_project"],
      "issue_types"   => ["project", "id", "issue_types_for_project"],
      "sub_task_issue_types"  => ["project", "id",
                                  "sub_task_issue_types_for_project"],
      "versions"      => ["project", "key"],
      "update"        => ["issue", "key",
                          "update_issue"],
    }

    def initialize(base, model, hash)
      @base, @model, @attributes = base, model, hash
    end

    def method_missing(method, *args)
      method = method.to_s
      if args.empty? and @attributes.has_key?(method)
        @attributes[method]
      elsif map = ASSOCIATIONS[method] and map.first == @model
        _, att, rp = map
        scope = att[-1] == ?s ? Array(@attributes[att[0..-2]]) : @attributes[att]
        args.unshift(scope)
        @base.send(rp || method, *args)
      else
        super(method.to_sym, *args)
      end
    end
  end
end
