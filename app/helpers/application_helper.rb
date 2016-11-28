module ApplicationHelper
  # Used to set a class onto an element containing a count.
  # Enables the use of the :after CSS pseudo-class to set
  # e.g. content: 'many' or content: 'one' on the element.
  # This helps solve the problem of the govuk_admin_template table filter
  # filtering rows based on the words 'Broken Link(s)' on the
  # Local Authority + Services index pages.
  def singular_or_plural(num)
    num == 1 ? 'singular' : 'plural'
  end

  # Used to set a compound cache key for fragment caches.
  # Namespaced to the controller and action, and with
  # a possible 'vary' string. The 'obj' parameter is expected to be
  # an ActiveRecord object, or at least something that implements the
  # #cache_key method.
  def namespaced_cache_key(obj, vary)
    [controller_name, controller.action_name, obj.cache_key, vary.to_s].join('/')
  end
end
