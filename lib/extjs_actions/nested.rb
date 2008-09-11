module ActiveScaffold::Actions
  module Nested
    def nested
      do_nested

      respond_to do |type|
        type.html { render :partial => 'nested', :layout => true }
        type.js { render :partial => 'nested.js.erb', :layout => false }
      end
    end
    
    def do_nested
      # I've folded loogic from the _nested.rhtml into the controller
      
      # This assumes that the association is included as a column in the active_scaffold_config.columns collection
      @record = find_if_allowed(params[:id], :read)
      associated_columns = []
      associated_columns = params[:associations].split(" ") unless params[:associations].nil?
      unless associated_columns.empty?
        parent_id = params[:id]
        associated_columns.each do | column_name |
          # find the column and the association
          column = active_scaffold_config.columns[column_name]
          association = column.association

          # determine what constraints we need
          if column.through_association?
            @constraints = {
              association.source_reflection.reverse => {
                association.through_reflection.reverse => parent_id
              }
            }
          else
            @constraints = { association.reverse => parent_id }
          end

          # generate the customized label
          @label = as_("%s for %s", active_scaffold_config_for(association.klass).label, format_column(@record.to_label))
      
    end
  end
end