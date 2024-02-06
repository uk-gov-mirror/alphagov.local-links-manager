class LocalAuthorityPresenter < SimpleDelegator
  include UrlStatusPresentation

  def homepage_status
    homepage_url.blank? ? "No link" : status_description
  end

  def homepage_link_last_checked
    homepage_url.blank? ? "" : last_checked
  end

  def authority_status
    return "inactive" unless active?
    return "active, but being retired" if active_end_date

    "active"
  end

  def should_display_end_notes?
    return true unless active?
    return true if active? && active_end_date

    false
  end

  def active_end_date_title
    active? ? "Date authority is due to become inactive" : "Date authority became inactive"
  end

  def summary_list(view_context)
    summary_items = [{ field: "Current Status", value: "<span class=\"govuk-tag govuk-tag--#{status_colour}\">#{authority_status}</span>".html_safe }]

    if should_display_end_notes?
      summary_items << { field: active_end_date_title, value: active_end_date.strftime("%F") }
      summary_items << { field: "Reason", value: active_note } if active_note.present?
      summary_items << { field: "Succeeding Authority", value: view_context.link_to(succeeded_by_local_authority.name, view_context.local_authority_path(succeeded_by_local_authority)) } if succeeded_by_local_authority
    end

    summary_items << { field: "Homepage URL", value: view_context.link_to_if(homepage_url, homepage_url, homepage_url, class: "govuk-link") }
    summary_items << { field: "Homepage Status", value: "<span class=\"govuk-tag govuk-tag--#{homepage_status_colour}\">#{homepage_status}</span> (last checked #{homepage_link_last_checked})".html_safe }
    summary_items << { field: "GSS", value: gss }
    summary_items << { field: "Local Custodian Code", value: local_custodian_code }
    summary_items << { field: "SNAC", value: snac }
    summary_items << { field: "Tier", value: tier.titleize }

    summary_items << { field: "Parent Authority", value: view_context.link_to(parent_local_authority.name, view_context.local_authority_path(parent_local_authority)) } if parent_local_authority

    { items: summary_items }
  end

  def status_colour
    return "grey" unless active?
    return "yellow" if active_end_date

    "green"
  end

  def homepage_status_colour
    case status
    when "caution"
      "yellow"
    when "broken"
      "red"
    else
      "green"
    end
  end
end
