class ChiliprojectLookAndFeelHookListener < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context = {})
    base_html = []
    base_html << stylesheet_link_tag('application', media: 'all', plugin: 'chiliproject_look_and_feel')
    base_html << stylesheet_link_tag('jquery/jquery-ui.theme', media: 'all', plugin: 'chiliproject_look_and_feel')
    base_html << javascript_include_tag('application', media: 'all', plugin: 'chiliproject_look_and_feel')
    selected_color_scheme = Setting.plugin_chiliproject_look_and_feel['color_scheme']
    if selected_color_scheme.present?
      base_html << stylesheet_link_tag("color_schemes/#{selected_color_scheme}", media: 'all', plugin: 'chiliproject_look_and_feel')
    end
    base_html.join("\n")
  end

  def view_layouts_base_body_bottom(context = {})
    stylesheet_link_tag('context_menu', media: 'all', plugin: 'chiliproject_look_and_feel')
  end

end
