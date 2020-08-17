class StripUrls < ActiveRecord::Migration[5.0]
  def change
    Link.all.each do |link|
      link.url.strip!
      link.save! if link.url_changed?
    end
  end
end
