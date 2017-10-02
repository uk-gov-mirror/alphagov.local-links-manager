module LinkFilterHelper
  def filtered_links(links)
    case params[:filter]
    when 'broken_links'
      links.broken_or_missing
    else
      links
    end
  end
end
