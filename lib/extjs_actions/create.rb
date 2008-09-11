module ActiveScaffold::Actions
  module Create
    def create
      do_create

      respond_to do |type|
        type.html do
          if params[:iframe]=='true' # was this an iframe post ?
            responds_to_parent do
              if successful?
                render :action => 'create.rjs', :layout => false
              else
                render :action => 'form_messages.rjs', :layout => false
              end
            end
          else
            if successful?
              flash[:info] = as_('Created %s', @record.to_label)
              return_to_main
            else
              render( :action => 'create_form', :layout => true)
            end
          end
        end
        type.js   { render :action => 'create.js.erb', :layout => false }
        type.json { render :action => 'create.json.erb', :layout => false }
        type.xml  { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end
  end
end