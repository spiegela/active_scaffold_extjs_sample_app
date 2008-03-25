module ActiveScaffold::Actions
  module List
    def list
      do_list
      respond_to do |type|
        type.html { render :action => 'list', :layout => true }
        type.json { render :action => 'list', :layout => false }
        type.xml  { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end
  end
  
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
        type.json { render :action => 'create', :layout => false }
        type.xml  { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end
  end
  
  module Delete
    def destroy
      return redirect_to(params.merge(:action => :delete)) if request.get?

      do_destroy

      respond_to do |type|
        type.html do
          flash[:info] = as_('Deleted %s', @record.to_label)
          return_to_main
        end
        type.js   { render(:action => 'destroy.js.erb', :layout => false) }
        type.json { render(:action => 'destroy', :layout => false) }
        type.xml  { render :xml => successful? ? "" : response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.json { render :text => successful? ? "" : response_object.to_json, :content_type => Mime::JSON, :status => response_status }
        type.yaml { render :text => successful? ? "" : response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end
  end
end