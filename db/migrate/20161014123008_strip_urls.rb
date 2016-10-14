class StripUrls < ActiveRecord::Migration
  def change
    Link.all.each do |link|
      link.url.strip!
      link.save! if link.url_changed?
    end
  end
end
