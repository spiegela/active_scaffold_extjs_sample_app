module ActiveScaffold
  module Helpers
    module FormColumns
      # This method decides which input to use for the given column.
      # It does not do any rendering. It only decides which method is responsible for rendering.
      def active_scaffold_input_for(column, scope = nil)
        options = active_scaffold_input_options(column, scope)

        # first, check if the dev has created an override for this specific field
        if override_form_field?(column)
          send(override_form_field(column), @record, options[:name])

        # second, check if the dev has specified a valid form_ui for this column
        elsif column.form_ui and override_input?(column.form_ui)
          send(override_input(column.form_ui), column, options)

        # fallback: we get to make the decision
        else
          if column.association
            # if we get here, it's because the column has a form_ui but not one ActiveScaffold knows about.
            raise "Unknown form_ui `#{column.form_ui}' for column `#{column.name}'"
          elsif column.virtual?
            active_scaffold_input_virtual(column, options)

          else # regular model attribute column
            # if we (or someone else) have created a custom render option for the column type, use that
            if override_input?(column.column.type)
              send(override_input(column.column.type), column, options)
            # final ultimate fallback: use rails' generic input method
            else
              # for textual fields we pass different options
              text_types = [:text, :string, :integer, :float, :decimal]
              options = active_scaffold_input_text_options(options) if text_types.include?(column.column.type)

              #input(:record, column.name, options)
              # Replace regular input with default ext.js input
              <<-EOS
              { fieldLabel: '#{column.label}',
                name: 'record[#{column.name}]',
                value: '#{@record.send(column.name)}',
                autoWidth: true,
                style: {'margin-right': '20px'}
              },
              EOS
            end
          end
        end
      end

      alias form_column active_scaffold_input_for

      ##
      ## Form input methods
      ##

      def active_scaffold_input_singular_association(column, options)
        associated = @record.send(column.association.name)

        select_options = [[as_('- select -'),nil]]
        select_options += [[ associated.to_label, associated.id ]] unless associated.nil?
        select_options += options_for_association(column.association)

        selected = associated.nil? ? nil : associated.id

        options[:name] += '[id]'
        select(:record, column.name, select_options.uniq, { :selected => selected }, options)
      end

      def active_scaffold_input_plural_association(column, options)
        associated_options = @record.send(column.association.name).collect {|r| [r.to_label, r.id]}
        select_options = associated_options | options_for_association(column.association)
        return 'no options' if select_options.empty?

        html = '<ul class="checkbox-list">'

        associated_ids = associated_options.collect {|a| a[1]}
        select_options.each_with_index do |option, i|
          label, id = option
          this_name = "#{options[:name]}[#{i}][id]"
          html << "<li>"
          html << check_box_tag(this_name, id, associated_ids.include?(id))
          html << "<label for='#{this_name}'>"
          html << label
          html << "</label>"
          html << "</li>"
        end

        html << '</ul>'
        html
      end

      def active_scaffold_input_select(column, options)
        if column.singular_association?
          active_scaffold_input_singular_association(column, options)
        elsif column.plural_association?
          active_scaffold_input_plural_association(column, options)
        else
          select(:record, column.name, column.options, { :selected => @record.send(column.name) }, options)
        end
      end

      # only works for singular associations
      # requires RecordSelect plugin to be installed and configured.
      # ... maybe this should be provided in a bridge?
      def active_scaffold_input_record_select(column, options)
        remote_controller = active_scaffold_controller_for(column.association.klass).controller_path

        # if the opposite association is a :belongs_to, then only show records that have not been associated yet
        params = if column.association and [:has_one, :has_many].include?(column.association.macro)
          {column.association.primary_key_name => ''}
        else
          {}
        end

        if column.singular_association?
          record_select_field(
            "#{options[:name]}",
            @record.send(column.name) || column.association.klass.new,
            {:controller => remote_controller, :id => options[:id], :params => params.merge(:parent_id => @record.id, :parent_model => @record.class)}.merge(active_scaffold_input_text_options).merge(column.options)
          )
        elsif column.plural_association?
          record_multi_select_field(
            options[:name],
            @record.send(column.name),
            {:controller => remote_controller, :id => options[:id], :params => params.merge(:parent_id => @record.id, :parent_model => @record.class)}.merge(active_scaffold_input_text_options).merge(column.options)
          )
        end
      end

      def active_scaffold_input_checkbox(column, options)
        check_box(:record, column.name, options)
      end

      def active_scaffold_input_country(column, options)
        priority = ["United States"]
        select_options = {:prompt => as_('- select -')}
        select_options.merge!(options)
        country_select(:record, column.name, column.options[:priority] || priority, select_options, column.options)
      end

      def active_scaffold_input_password(column, options)
        password_field :record, column.name, active_scaffold_input_text_options(options)
      end

      def active_scaffold_input_textarea(column, options)
        text_area(:record, column.name, options.merge(:cols => column.options[:cols], :rows => column.options[:rows]))
      end

      def active_scaffold_input_usa_state(column, options)
        select_options = {:prompt => as_('- select -')}
        select_options.merge!(options)
        select_options.delete(:size)
        options.delete(:prompt)
        options.delete(:priority)
        usa_state_select(:record, column.name, column.options[:priority], select_options, column.options.merge!(options))
      end

      def active_scaffold_input_virtual(column, options)
        <<-EOS
        { fieldLabel: '#{column.label}',
          name: 'record[#{column.name}]'
        },
        EOS
      end
      
      def form_partial_for_column(column)
        if override_form_field_partial?(column)
          override_form_field_partial(column)
        elsif column_renders_as(column) == :field or override_form_field?(column)
          "form_attribute.js.erb"
        elsif column_renders_as(column) == :subform
          "form_association.js.erb"
        elsif column_renders_as(column) == :hidden
          "form_hidden_attribute.js.erb"
        end
      end
    end
  end
end