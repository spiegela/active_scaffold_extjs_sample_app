module ActiveScaffold::Actions
  module List
    def list
      do_list
      respond_to do |type|
        type.html { render :action => 'list', :layout => true }
        type.js   { render :action => 'list.js.erb', :layout => true }
        type.json { render :action => 'list.json.erb', :layout => false}
        type.xml  { render :xml => response_object.to_xml, :content_type => Mime::XML, :status => response_status }
        type.yaml { render :text => response_object.to_yaml, :content_type => Mime::YAML, :status => response_status }
      end
    end
    
    protected
    
    # The actual algorithm to prepare for the list view
    def do_list
      includes_for_list_columns = active_scaffold_config.list.columns.collect{ |c| c.includes }.flatten.uniq.compact
      self.active_scaffold_joins.concat includes_for_list_columns
    
      options = {:sorting => active_scaffold_config.list.user.sorting,}
      paginate = (params[:format].nil?) ? (accepts? :html, :js, :json) : [:html, :js, :json].include?(params[:format])
      if paginate
        options.merge!({
          :per_page => active_scaffold_config.list.user.per_page,
          :page => active_scaffold_config.list.user.page
        })
      end
    
      page = find_page(options);
      if page.items.empty?
        page = page.pager.first
        active_scaffold_config.list.user.page = 1
      end
      @page, @records = page, page.items
    end
    
    # The default security delegates to ActiveRecordPermissions.
    # You may override the method to customize.
    def list_authorized?
      authorized_for?(:action => :read)
    end
  end
end