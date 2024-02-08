desc "Updates Service records with titles/links to the GOV.UK finder documents "
task service_urls_from_govuk: :environment do
  content_store_api = GdsApi.content_store
  local_transaction_pages = GdsApi.search.search({ filter_format: "local_transaction", count: 200, fields: "title,link,content_id" })

  local_transaction_pages["results"].each do |lap|
    ci = content_store_api.content_item(lap["link"])
    lgsl = ci.to_hash["details"]["lgsl_code"]
    lgil = ci.to_hash["details"]["lgil_code"]
    puts("#{lgsl},#{lgil},#{lap['title']},#{lap['link']}")
  end
end
