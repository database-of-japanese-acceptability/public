# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def control
    control = "<div id='login_menu'>"
    if !$conf[:authenticate] or logged_in?
      control << "<span class='menu'>" + link_to_unless_current("[Convert]", :controller => "msfa", :action => "upload") + "</span>"
      if $conf[:authenticate]
        control << "<span class='menu'>" + link_to("[Logout]", :controller=>'account', :action=>'logout') + "</span>"
      end
    else
      control << "<span class='menu'>" + link_to_unless_current('[Login]', :controller=>'account', :action=>'login') + "</span>"
    end    
      # control << "<span class='menu'>" + link_to("[RFCA]", "http://yohasebe.com/rb/rfca") + "</span>"
    control << "</div>"

    actions = [
      ["Home (Wiki)", {:controller => "wiki", :action => "index"}],
      ["MSFA List", {:controller => "sentence", :action => "list"}],
      ["Frame List", {:controller => "frame", :action => "list"}],
      ["Element List", {:controller => "primitive", :action => "list"}],
      ["Relation List", {:controller => "relation", :action => "list"}],
      ["Morph List", {:controller => "morpheme", :action => "list"}],
      ["Phrase List", {:controller => "phrase", :action => "list"}],
    ]

    control <<  "<div id='banner'>"
    control << link_to("AMPS <small>Another MSFA Processing System</small>", 
                        :controller => "wiki", :action => "index")
    control << "</div>\n"
    control << "<div id='main_menu'>"
    actions.each do |ctrl|
      if controller.controller_name == ctrl[1][:controller]
        control << "<span class='menu_current'>"
      else
        control << "<span class='menu'>"
      end  
      control << link_to(ctrl[0], ctrl[1])
      control << "</span>"
    end
    control << "</div>"
    control
  end
    
  def search_link(collection, keyword)
    keyword = nil if keyword == ""
    search = keyword ? {:search => {:text => keyword}} : {}
    result = "<div class='control_link'>"
    result << collection.size.to_s + " 件中 " + "\n"
    prev_count = (collection.page - 1) * collection.page_size
    if  collection.next_page?
      result << (prev_count + 1).to_s + '-' + (prev_count + collection.page_size).to_s +  " 件目<br />" + "\n"
    else
      result << (prev_count + 1).to_s + '-' + collection.size.to_s +  " 件目<br />" + "\n"
    end
    if collection.page != collection.first_page
      result << link_to("前へ", {:action=>'list', :page=>collection.previous_page}.update(search)) + "\n"
    end
    if collection.page != collection.first_page
      result << link_to('1 ', {:action=>'list', :page=>collection.first_page}.update(search)) + "\n"
    end
    if collection.previous_page? and collection.previous_page != collection.first_page
      result << " ... " + "\n"
      result << link_to(collection.previous_page, {:action=>'list', :page => collection.previous_page}.update(search)) + "\n"
    end
    result << " " + collection.page.to_s + " "  + "\n"
    if collection.next_page? and collection.next_page != collection.last_page
      result << link_to(collection.next_page, {:action=>'list', :page=>collection.next_page}.update(search)) + "\n"
      result << " ... "  + "\n"
    end
    if collection.page != collection.last_page
      result << link_to(collection.page_count, {:action=>'list', :page=>collection.last_page}.update(search)) + "\n"
    end
    if collection.page != collection.last_page
      result << link_to("次へ", {:action=>'list', :page=>collection.next_page}.update(search)) + "\n"
    end
    result << "</div>"
    result
  end

  def find_link(collection, form, ids = "")
    result = "<div class='control_link'>"
    result << collection.size.to_s + " 件中 " + "\n"
    prev_count = (collection.page - 1) * collection.page_size
    if  collection.next_page?
      result << (prev_count + 1).to_s + '-' + (prev_count + collection.page_size).to_s +  " 件目<br />" + "\n"
    else
      result << (prev_count + 1).to_s + '-' + collection.size.to_s +  " 件目<br />" + "\n"
    end
    if collection.page != collection.first_page
      result << link_to("前へ", :action=>'show', :page=>collection.previous_page,
                                :form => form, :method => :post, :ids => ids) + "\n"
    end
    if collection.page != collection.first_page
      result << link_to('1 ', :action=>'show', :page=>collection.first_page, 
                              :form => form, :method => :post, :ids => ids) + "\n"
    end
    if collection.previous_page? and collection.previous_page != collection.first_page
      result << " ... " + "\n"
      result << link_to(collection.previous_page, :action=>'show', :page=>collection.previous_page,
                              :form => form, :method => :post, :ids => ids) + "\n"
    end
    result << " " + collection.page.to_s + " "  + "\n"
    if collection.next_page? and collection.next_page != collection.last_page
      result << link_to(collection.next_page, :action=>'show', :page=>collection.next_page,
                                              :form => form, :method => :post, :ids => ids) + "\n"
      result << " ... "  + "\n"
    end
    if collection.page != collection.last_page
      result << link_to(collection.page_count, :action=>'show', :page=>collection.last_page,
                                              :form => form, :method => :post, :ids => ids) + "\n"
    end
    if collection.page != collection.last_page
      result << link_to("次へ", :action=>'show', :page=>collection.next_page,
                                :form => form, :method => :post, :ids => ids) + "\n"      
    end
    result << "</div>"
    result
  end
end
