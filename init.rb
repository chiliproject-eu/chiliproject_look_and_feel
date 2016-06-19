Redmine::Plugin.register :chiliproject_look_and_feel do
  name 'ChiliProject Look & Feel'
  author 'ChiliProject.eu'
  description 'ChiliProject Look & Feel adds the original ChiliProject theme and menu style'
  version '0.0.6'
  url 'http://www.chiliproject.eu/projects/chiliproject/wiki/ChiliProject_Look_and_Feel_Plugin'
  author_url 'http://www.chiliproject.eu'

  settings default: { }, partial: 'settings/chiliproject_look_and_feel'

  issue_query_proc = ->(p) {
    sidebar_queries = IssueQuery.visible.
      order("#{Query.table_name}.name ASC").
      # Project specific queries and global queries
      where(p.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", p.id]).
      to_a

    sidebar_queries.collect do |query|
      Redmine::MenuManager::MenuItem.new("query-#{query.id}".to_sym, { :controller => 'issues', :action => 'index', :project_id => p, :query_id => query }, {
        :caption => query.name,
        :param => :project_id,
        :parent => :issues
      })
    end
  }

  if roadmap_menu_item = Redmine::MenuManager.items(:project_menu).detect { |n| n.name == :roadmap }
    roadmap_child_menus = Proc.new { |p|
      versions = p.shared_versions.sort
      versions.reject! {|version| version.closed? || version.completed? }

      versions.collect do |version|
        Redmine::MenuManager::MenuItem.new("version-#{version.id}".to_sym,
          { :controller => 'versions', :action => 'show', :id => version },
          { :caption => version.name, :parent => :roadmap }
        )
      end
    }
    roadmap_menu_item.instance_variable_set('@child_menus', roadmap_child_menus)
  end

  if issues_menu_item = Redmine::MenuManager.items(:project_menu).detect { |n| n.name == :issues }
    issues_menu_item.instance_variable_set('@child_menus', issue_query_proc)
  end

  menu(:project_menu, :time_entries, { :controller => 'timelog', :action => 'index' }, {
    :caption => :label_time_entry_plural,
    :param => :project_id,
    :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) }
  });

  menu(:project_menu, :new_time_entry, { :controller => 'timelog', :action => 'new' }, {
    :caption => :field_time_entries,
    :param => :project_id,
    :if => Proc.new {|p| User.current.allowed_to?(:log_time, p) },
    :parent => :time_entries
  })

  if new_issue_menu_item = Redmine::MenuManager.items(:project_menu).detect { |n| n.name == :new_issue }
    Redmine::MenuManager.items(:project_menu).remove! new_issue_menu_item
  end

  menu :project_menu, :new_issue, { :controller => 'issues', :action => 'new', :copy_from => nil }, :param => :project_id, :caption => :label_issue_new,
    :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) },
    :if => Proc.new { |p| p.trackers.any? },
    :permission => :add_issues,
    :parent => :issues

  menu(:project_menu, :all_issues, { :controller => 'issues', :action => 'index', :set_filter => 1 }, {
    :param => :project_id,
    :caption => :label_issue_view_all,
    :parent => :issues
  })

  menu(:project_menu, :report, { :controller => 'reports', :action => 'issue_report' }, {
    :caption => :field_summary,
    :parent => :issues
  })

  menu(:project_menu, :new_query, { :controller => 'queries', :action => 'new' }, {
    :caption => :label_query_new,
    :parent => :issues
  })

  if Redmine::VERSION::MAJOR >= 3 && Redmine::VERSION::MINOR >= 2
    menu(:project_menu, :new_import, { :controller => 'imports', :action => 'new' }, {
      :caption => :label_import_issues,
      :parent => :issues
    })
  end

  menu(:project_menu, :new_news, {:controller => 'news', :action => 'new' }, {
    :param => :project_id,
    :caption => :label_news_new,
    :parent => :news,
    :if => Proc.new {|p| User.current.allowed_to?(:manage_news, p) }
  })

  menu(:project_menu, :new_document, { :controller => 'documents', :action => 'new' }, {
    :param => :project_id,
    :caption => :label_document_new,
    :parent => :documents,
    :if => Proc.new {|p| User.current.allowed_to?(:manage_documents, p) }
  })

  menu(:project_menu, :wiki_by_title, { :controller => 'wiki', :action => 'index' }, {
    :caption => :label_index_by_title,
    :parent => :wiki,
    :param => :project_id,
    :if => Proc.new { |p| p.wiki && !p.wiki.new_record? }
  })

  menu(:project_menu, :wiki_by_date, { :controller => 'wiki', :action => 'date_index'}, {
    :caption => :label_index_by_date,
    :parent => :wiki,
    :param => :project_id,
    :if => Proc.new { |p| p.wiki && !p.wiki.new_record? }
  })

  if boards_menu_item = Redmine::MenuManager.items(:project_menu).detect { |n| n.name == :boards }
    board_child_menus = Proc.new {|project|
      project.boards.select { |b| b.persisted? }.collect do |board|
        Redmine::MenuManager::MenuItem.new(
         "board-#{board.id}".to_sym,
         { :controller => 'boards', :action => 'show', :project_id => project, :id => board },
         {
           :caption => board.name # is h() in menu_helper.rb
         })
      end
    }
    boards_menu_item.instance_variable_set('@child_menus', board_child_menus)
  end

  menu(:project_menu, :new_board, { :controller => 'boards', :action => 'new' }, {
    :caption => :label_board_new,
    :param => :project_id,
    :parent => :boards,
    :if => Proc.new {|p| User.current.allowed_to?(:manage_boards, p) }
  })

  menu(:project_menu, :new_file, { :controller => 'files', :action => 'new' }, {
    :caption => :label_attachment_new,
    :param => :project_id,
    :parent => :files,
    :if => Proc.new {|p| User.current.allowed_to?(:manage_files, p) }
  })

  if settings_menu_item = Redmine::MenuManager.items(:project_menu).detect { |n| n.name == :settings }
    settings_child_menus = ->(p) {
      h = Class.new { include(ProjectsHelper) }.new
      h.instance_variable_set('@project', p)
      h.project_settings_tabs.collect do |tab|
        Redmine::MenuManager::MenuItem.new("settings-#{tab[:name]}".to_sym,
          { :controller => 'projects', :action => 'settings', :id => p, :tab => tab[:name] },
          { :caption => tab[:label] }
        )
      end
    }
    settings_menu_item.instance_variable_set('@child_menus', settings_child_menus)
  end

end

ActionDispatch::Callbacks.to_prepare do
  unless Redmine::Hook.listeners.any? { |l| l.class.name == 'ChiliprojectLookAndFeelHookListener' }
    require_dependency 'chiliproject_look_and_feel_hook_listener'
  end
  require_dependency 'chiliproject_look_and_feel/application_helper_patch'
end
