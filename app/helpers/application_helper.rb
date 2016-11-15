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
end
