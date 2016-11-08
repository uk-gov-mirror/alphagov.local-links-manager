module Sortable
  extend ActiveSupport::Concern

  included do
    def current_sort_order
      {
        description: I18n.t(sort_order.keys.first),
        param: sort_order.keys.first
      }
    end
    helper_method :current_sort_order

    def all_sort_order_options
      sort_order_options.map do |key, _|
        {
          description: I18n.t(key),
          param: key
        }
      end
    end
    helper_method :all_sort_order_options
  end
end
