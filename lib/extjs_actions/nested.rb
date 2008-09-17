module ActiveScaffold::Actions
  module Nested
    def nested
      do_nested

      respond_to do |type|
        type.html { render :partial => 'nested', :layout => true }
        type.js { render :partial => 'nested.js.erb', :layout => false }
      end
    end
  end
  
  def do_nested
    @record = find_if_allowed(params[:id], :read)
    @associations = []
    associated_columns = []
    associated_columns = params[:associations].split(" ") unless params[:associations].nil?
    unless associated_columns.empty?
      parent_id = params[:id]
      associated_columns.each_with_index do | column_name, index |
        associations[index] = {}
        # find the column and the association
        column = active_scaffold_config.columns[column_name]
        association = column.association

        # determine what constraints we need
        if column.through_association?
          @associations[index][:constraints] = {
            association.source_reflection.reverse => {
              association.through_reflection.reverse => parent_id
            }
          }
        else
          @associations[index][:constraints] = { association.reverse => parent_id }
        end

        # generate the customized label
        @associations[index][:label] = as_("%s for %s", active_scaffold_config_for(association.klass).label, format_column(@record.to_label))
        controller = active_scaffold_controller_for(association.klass)
        @associations[index][:controller] = controller
        @associations[index][:url] = url_for(controller.controller_path, :constraints => @constraints)
      end
    end
  end
end