require_dependency 'application_helper'

module ApplicationHelperPatch

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      def page_header_title_with_explicit_declaration
        if @page_header_title.present?
          h(@page_header_title)
        else
          page_header_title_without_explicit_declaration
        end
      end
      alias_method_chain :page_header_title, :explicit_declaration
  
      def sidebar_content?
        content_for?(:sidebar) || content_for?(:main_menu) || view_layouts_base_sidebar_hook_response.present?
      end

      def favicon_path
        icon = (current_theme && current_theme.favicon?) ? current_theme.favicon_path : '/plugin_assets/chiliproject_look_and_feel/favicon.ico'
        image_path(icon)
      end

      # Menu items for the main top menu
      def main_top_menu_items
        split_top_menu_into_main_or_more_menus[:main]
      end

      # Menu items for the more top menu
      def more_top_menu_items
        split_top_menu_into_main_or_more_menus[:more]
      end

      def help_menu_item
        split_top_menu_into_main_or_more_menus[:help]
      end

      # Split the :top_menu into separate :main and :more items
      def split_top_menu_into_main_or_more_menus
        unless @top_menu_split
          items_for_main_level = []
          items_for_more_level = []
          help_menu = nil
          menu_items_for(:top_menu) do |item|
            if item.name == :home || item.name == :my_page
              items_for_main_level << item
            elsif item.name == :help
              help_menu = item
            elsif item.name == :projects
              # Remove, present in layout
            else
              items_for_more_level << item
            end
          end
          @top_menu_split = {
            :main => items_for_main_level,
            :more => items_for_more_level,
            :help => help_menu
          }
        end
        @top_menu_split
      end

      # Expands the current menu item using JavaScript based on the params
      def expand_current_menu
        current_menu_class =
          case
          when params[:controller] == "timelog"
            "reports"
          when params[:controller] == 'projects' && params[:action] == 'changelog'
            "reports"
          when params[:controller] == 'issues' && ['calendar','gantt'].include?(params[:action])
            "reports"
          when params[:controller] == 'projects' && params[:action] == 'roadmap'
            'roadmap'
          when params[:controller] == 'versions' && params[:action] == 'show'
            'roadmap'
          when params[:controller] == 'projects' && params[:action] == 'settings'
            'settings'
          when params[:controller] == 'contracts' || params[:controller] == 'deliverables'
            'contracts'
          else
            params[:controller]
          end


        javascript_tag("jQuery.menu_expand({ menuItem: '.#{current_menu_class}' });")
      end
    end
  end

  module ClassMethods
  end

  module InstanceMethods
  end

end

ApplicationHelper.send(:include, ApplicationHelperPatch)
