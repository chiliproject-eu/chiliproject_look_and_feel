class ChiliprojectLookAndFeelHookListener < Redmine::Hook::ViewListener

  def view_layouts_base_html_head(context = {})
    stylesheet_link_tag('application', media: 'all', plugin: 'chiliproject_look_and_feel') +
    stylesheet_link_tag('jquery/jquery-ui.theme', media: 'all', plugin: 'chiliproject_look_and_feel') +
    javascript_include_tag('application', media: 'all', plugin: 'chiliproject_look_and_feel')
  end

end
