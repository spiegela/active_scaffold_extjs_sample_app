module ActiveScaffold::Actions
  module List
    def list
      do_list
      respond_to do |type|
        type.html {
          render :action => 'list', :layout => true
        }
        type.json {
          render :action => 'list', :layout => false
        }
        type.xml { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end
  end
  
  module Create
    def new
      do_new

      respond_to do |type|
        type.html do
          if successful?
            render(:action => 'create_form', :layout => true)
          else
            return_to_main
          end
        end
        type.js do
          render(:partial => 'create_form.js.erb', :layout => false)
        end
      end
    end
  end
end