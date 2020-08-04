require "csv"
require "local-links-manager/link_resolver"

LGSL_LGIL_PAIRS = [
  [1, 8],
  [2, 8],
  [3, 8],
  [4, 0],
  [12, 8],
  [13, 0],
  [14, 0],
  [18, 8],
  [19, 8],
  [35, 8],
  [36, 8],
  [40, 0],
  [48, 0],
  [55, 8],
  [57, 8],
  [59, 0],
  [63, 0],
  [69, 8],
  [72, 8],
  [88, 0],
  [92, 0],
  [101, 8],
  [107, 0],
  [112, 8],
  [115, 0],
  [124, 8],
  [137, 0],
  [141, 0],
  [147, 8],
  [151, 8],
  [159, 0],
  [160, 0],
  [178, 0],
  [209, 0],
  [260, 0],
  [272, 8],
  [273, 0],
  [274, 8],
  [279, 8],
  [280, 0],
  [287, 0],
  [296, 8],
  [297, 8],
  [313, 0],
  [315, 8],
  [328, 8],
  [353, 8],
  [358, 8],
  [364, 8],
  [372, 17],
  [412, 17],
  [415, 8],
  [428, 8],
  [431, 0],
  [431, 8],
  [432, 8],
  [432, 8],
  [437, 8],
  [438, 8],
  [439, 0],
  [439, 8],
  [440, 8],
  [442, 8],
  [444, 8],
  [448, 8],
  [461, 8],
  [471, 8],
  [471, 4],
  [474, 8],
  [477, 0],
  [493, 8],
  [508, 0],
  [510, 0],
  [512, 0],
  [516, 8],
  [524, 17],
  [524, 8],
  [528, 0],
  [530, 8],
  [533, 0],
  [533, 8],
  [537, 17],
  [541, 8],
  [546, 8],
  [550, 17],
  [555, 17],
  [557, 17],
  [558, 8],
  [559, 17],
  [561, 8],
  [564, 17],
  [567, 8],
  [568, 0],
  [571, 8],
  [576, 17],
  [577, 17],
  [580, 17],
  [580, 8],
  [584, 17],
  [586, 8],
  [587, 17],
  [588, 17],
  [591, 17],
  [600, 17],
  [603, 8],
  [615, 8],
  [631, 8],
  [664, 8],
  [684, 17],
  [703, 8],
  [831, 8],
  [850, 8],
  [852, 8],
  [859, 0],
  [860, 8],
  [867, 8],
  [870, 8],
  [1116, 0],
  [1135, 8],
  [1140, 8],
  [1145, 8],
  [1307, 8],
  [1579, 8],
  [1580, 0],
  [1741, 8],
  [1742, 8],
  [1743, 8],
].freeze

def las_with_missing_links_for_services(service, service_interaction)
  # How many LAs should have links for services?
  should_las = service.local_authorities.pluck(:slug).sort

  # How many LAs actually do have links for services?
  does_las = []
  service.service_tiers.each do |tier|
    does_las += Link.joins(:local_authority).where(service_interaction: service_interaction, local_authorities: { tier_id: tier.tier_id }).map { |link| link.local_authority.slug }
  end

  doesnt = should_las - does_las
  doesnt
end

HEADERS = %w[la lgsl lgil link].freeze
CSV.open("lgsl_lgil_fallback_links.csv", "w") do |csv|
  csv << HEADERS

  LGSL_LGIL_PAIRS.each do |p|
    lgsl_code = p[0]
    lgil_code = p[1]

    s = Service.find_by(lgsl_code: lgsl_code)
    i = Interaction.find_by(lgil_code: lgil_code)
    si = ServiceInteraction.lookup_by_lgsl_and_lgil(lgsl_code, lgil_code)

    missing = las_with_missing_links_for_services(s, si)

    # Try to resolve links using the fallback mechanism.
    missing.each do |m|
      la = LocalAuthority.where(slug: m).first
      found_link = LocalLinksManager::LinkResolver.new(la, s).resolve
      if found_link
        csv << [la.slug, s.slug, i.slug, found_link.url, lgsl_code, lgil_code]
      end
    end
  end
end
