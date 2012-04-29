module ApplicationHelper

  def title(page_title)
    content_for(:title) { page_title }
  end
=beging
  def multi_language_form(destination)
     destination = controller.controller_name.to_s + '/' + destination 
     html = ""
     html << multi_language_form_tab
     html << render(:partial => destination)
     I18n.locale = params[:locale]
     html.html_safe
  end
  
  def multi_language_form_tab
    html = ""
    html << '<ul class="select-form-language">'
    @locales.each do |locale|
      I18n.locale.to_s == locale.language ? ts = ' tab-selected' : ts = '' 
      javascript_function =  "$('.multilanguage').hide();$('.multilanguage-menu').css('background-color','#FFF');"
      javascript_function << "$('#form-#{locale.language}').show();$('#tab-#{locale.language}').css('background-color','#DDD')"
      html << "<li id=\"tab-#{locale.language}\" class=\"multilanguage-menu#{ts}\" >"
      html << link_to_function(locale.name, javascript_function)
      html << "</li>" 
    end
    html << "</ul>"
    html.html_safe
  end
=end
end
