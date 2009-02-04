require 'time'

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

    # FIXME: DRY this up a little bit
    CONVERTERS = {
      'resolution' => lambda {|s,x| s.base.resolutions.detect {|r| r.id == x}},
      'priority'   => lambda {|s,x| s.base.priorities.detect {|p| p.id == x}},
      'status'     => lambda {|s,x| s.base.statuses.detect {|p| p.id == x}},
      'project'    => lambda {|s,x| s.base.projects.detect {|p| p.key == x}},
      'type'       => lambda { |s,x|
        p = s.project
        (p.issue_types + p.sub_task_issue_types).detect {|it| it.id == x}
      },
      'lead' => lambda {|s,x| s.base.user(x)},
      'author' => lambda {|s,x| s.base.user(x)},
      'reporter' => lambda {|s,x| s.base.user(x)},
      'assignee' => lambda {|s,x| s.base.user(x)},
      'components' => lambda {|s,x| x.map {|c| Model.new(s.base, 'component', c)}},
      'affects_versions' => lambda {|s,x| x.map {|v| Model.new(s.base, 'version', v)}},
      'fix_versions' => lambda {|s,x| x.map {|v| Model.new(s.base, 'version', v)}},
      'created' => lambda {|s,x| Time.parse(x)},
      'updated' => lambda {|s,x| Time.parse(x)},
      'release_date' => lambda {|s,x| Date.parse(x)},
      'build_date' => lambda {|s,x| Date.parse(x)},
      'archived' => lambda {|s,x| x == 'true'},
      'released' => lambda {|s,x| x == 'true'},
      'sub_task' => lambda {|s,x| x == 'true'},
    }

    BOOLEANS = %w{archived released sub_task}

    attr_reader :base, :model

    def initialize(base, model, hash)
      @base, @model, @attributes = base, model, hash
      @attributes.keys.each do |key|
        new_key = key.gsub(/[A-Z]/) {"_#{$&.downcase}"}
        if key != new_key
          @attributes[new_key] = @attributes.delete(key)
        end
      end
    end

    def id
      @attributes['id']
    end

    def type
      CONVERTERS['type'].call(self, @attributes['type'])
    end

    def method_missing(method, *args)
      method = method.to_s
      if method[-1] == ?? and BOOLEANS.include?(method[0..-2])
        method = method[0..-2]
      end
      if args.empty? and @attributes.has_key?(method)
        att = @attributes[method]
        if converter = CONVERTERS[method]
          converter.call(self, att)
        else
          att
        end
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
