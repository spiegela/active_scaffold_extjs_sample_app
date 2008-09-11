module ActiveScaffold::Actions
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