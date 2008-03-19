 module ActiveScaffold
  module Helpers
    module ViewHelpers
      def action_link_options(link, url_options)
        url_options[:action] = link.action
        url_options[:controller] = link.controller if link.controller
        url_options.delete(:search) if link.controller and link.controller.to_s != params[:controller]
        url_options.merge! link.parameters if link.parameters

        html_options = {:class => link.action}
        if link.inline?
          # NOTE this is in url_options instead of html_options on purpose. the reason is that the client-side
          # action link javascript needs to submit the proper method, but the normal html_options[:method]
          # argument leaves no way to extract the proper method from the rendered tag.
          url_options[:_method] = link.method

          if link.method != :get and respond_to?(:protect_against_forgery?) and protect_against_forgery?
            url_options[:authenticity_token] = form_authenticity_token
          end
        else
          # Needs to be in html_options to as the adding _method to the url is no longer supported by Rails
          html_options[:method] = link.method
        end

        html_options[:confirm] = link.confirm if link.confirm?
        html_options[:position] = link.position if link.position and link.inline?
        html_options[:class] += ' action' if link.inline?
        html_options[:popup] = true if link.popup?
        html_options[:id] = action_link_id(url_options[:action],url_options[:id])

        if link.dhtml_confirm?
          html_options[:class] += ' action' if !link.inline?
          html_options[:page_link] = 'true' if !link.inline?
          html_options[:dhtml_confirm] = link.dhtml_confirm.value
          html_options[:onclick] = link.dhtml_confirm.onclick_function(controller,action_link_id(url_options[:action],url_options[:id]))
        end
        return url_options, html_options
      end

      def render_action_link(link, url_options)
        url_options = url_options.clone
         # issue 260, use url_options[:link] if it exists. This prevents DB data from being localized.
        label = url_options.delete(:link) || link.label
        html_options, url_options = action_link_options(link, url_options)
        link_to label, html_options, url_options
      end
    end
  end
end