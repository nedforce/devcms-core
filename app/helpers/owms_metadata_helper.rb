module OwmsMetadataHelper
  def generate_metadata_for(node)
    metadata = []

    metadata << tag(:link, rel: 'schema.DCTERMS', href: 'http://purl.org/dc/terms')
    metadata << tag(:link, rel: 'schema.OVERHEID', href: 'http://standaarden.overheid.nl/owms/terms')

    metadata << indexing_metadata_for(node)    
    metadata << owms_core_metadata_for(node)
    metadata << owms_permit_metadata_for(node) if node.content_type == 'Permit'

    metadata << meta_tag('keywords', node.tag_list.join(","))

    metadata << meta_tag('DCTERMS.alternative', node.title_alternative_list.to_s) if node.title_alternative_list.present?

    metadata.flatten.join("\n").html_safe
  end

  # For content to be OWMS-conform, 8 core OWMS properties must be specified:
  # * dcterms:identifier (Verwijzing)
  # * dcterms:title (Titel)
  # * dcterms:type (Informatietype)
  # * dcterms:language (Taal)
  # * dcterms:creator (Maker)
  # * dcterms:modified (Wijzigingsdatum)
  # * dcterms:created (Aanmaakdatum)
  # * dcterms:available (Publicatiedatum range)
  # * dcterms:spatial (Locatie)
  # * dcterms:temporal (Dekking in tijd)
  def owms_core_metadata_for(node)
    content = node.content
    tags = []
    tags << meta_tag('DCTERMS.identifier', node_url(node),                                                                            'DCTERMS.URI')
    tags << meta_tag('DCTERMS.title',      @page_title)
    tags << meta_tag('DCTERMS.type',       content.class.respond_to?(:owms_type) ? content.class.owms_type : I18n.t('owms.web_page'), 'OVERHEID.Informatietype')
    tags << meta_tag('DCTERMS.language',   'nl-NL',                                                                                   'DCTERMS.RFC4646')
    tags << meta_tag('DCTERMS.creator',    Settler[:site_name],                                                                       'OVERHEID.Gemeente')
    tags << meta_tag('DCTERMS.modified',  (content.updated_at || content.created_at).utc.to_s(:w3cdtfutc),                            'DCTERMS.W3CDTF')
    tags << meta_tag('DCTERMS.created',    content.created_at.utc.to_s(:w3cdtfutc),                                                   'DCTERMS.W3CDTF')
    # Construct available period
    period = "start=#{node.publication_start_date.utc.to_s(:w3cdtfutc)};"
    period << " end=#{node.publication_end_date.utc.to_s(:w3cdtfutc)};" if node.publication_end_date.present?
    tags << meta_tag('DCTERMS.available',  "#{period} scheme=W3C-DTF;",                                                               'DCTERMS.Period')
    tags << meta_tag('DCTERMS.spatial',    Settler[:site_name],                                                                       'OVERHEID.Gemeente')
    tags << meta_tag('DCTERMS.temporal',   content.respond_to?(:owms_temporal) ? content.owms_temporal : '',                          'ODCTERMS.Period')
    tags
  end

  # OWMS fields specifically meant for announcements (bm) and permits (vg)
  #
  # * DC.type/overheidbm.producttype (scheme OVERHEIDbm.bekendmakingtypeGemeente, OVERHEIDbm.bekendmakingtypeProvincie, OVERHEIDbm.bekendmakingtypeGemeente)
  # * DC.type/overheidbm.producttype (scheme OVERHEIDvg.Product)
  # * OVERHEID.organisationType (see http://metadata.overheid.nl/development/vocabularies/OVERHEID.Organisatietype.txt)
  # * DC.publisher
  # * DC.creator
  # * OVERHEIDbm.referentieNummer
  # * DCTERMS.spatial (scheme OVERHEIDvg.perceel)
  # * OVERHEIDbm.sectie
  #
  # ==== phases ====
  # * OVERHEIDvg.phase (scheme OVERHEIDvg.faseVergunning, OVERHEIDvg.faseBezwaarBeroep, OVERHEIDvg.status
  # * OVERHEIDvg.status (scheme OVERHEIDvg.status)
  # * OVERHEIDbm.termijnsoort
  # * OVERHEIDbm.startdatumTermijn (scheme dcterms:W3CDTF)
  # * OVERHEIDbm.einddatumTermijn (scheme dcterms:W3CDTF)
  #
  # ==== locations ====
  # * DCTERMS.spatial (scheme OVERHEIDbm.postcode)
  # * DCTERMS.spatial (scheme OVERHEID.PostcodeHuisnummer)
  # * DCTERMS.spatial (scheme OVERHEID.gemeente)
  # * DCTERMS.spatial (scheme OVERHEIDbm.woonplaats)
  # * DCTERMS.spatial (scheme OVERHEIDvg.adres)
  # * DCTERMS.spatial (scheme OVERHEIDbm.straat)
  # * DCTERMS.spatial (scheme OVERHEIDvg.huisnummer)
  #
  # ==== coordinates ====
  # * DCTERMS.spatial (scheme OVERHEIDbm.x-waarde)
  # * DCTERMS.spatial (scheme OVERHEIDbm.y-waarde)
  # * OVERHEIDVG.coordinaten, format 'x=(\d+), y=(\d+)'
  def owms_permit_metadata_for(node)
    permit = node.content
    tags = []

    tags << meta_tag('DC.type', permit.product_type, 'OVERHEIDbm.bekendmakingtypeGemeente')
    #tags << meta_tag('DC.type', permit.product_type, 'OVERHEIDvg.Product')
    tags << meta_tag('OVERHEID.organisationType', 'gemeente')
    tags << meta_tag('DC.publisher', Settler[:site_name], 'OVERHEID.Gemeente')
    tags << meta_tag('DC.creator',   Settler[:site_name], 'OVERHEID.Gemeente')
    tags << meta_tag('OVERHEIDbm.referentieNummer', permit.reference)
    # ==== parcels ====
    permit.parcels.each { |parcel| tags << [ meta_tag('DCTERMS.spatial', parcel.number, 'OVERHEIDvg.perceel'), meta_tag('OVERHEIDbm.sectie', parcel.section) ] }
    # ==== phases ====
    tags << meta_tag('OVERHEIDvg.phase',             permit.phase, Permit::PERMIT_PHASES.include?(permit.phase) ? 'OVERHEIDvg.faseVergunning' : 'OVERHEIDvg.faseBezwaarBeroep') if permit.phase.present?
    # tags << meta_tag('OVERHEIDvg.status', (scheme OVERHEIDvg.status)
    tags << meta_tag('OVERHEIDbm.termijnsoort',      permit.period_type)
    tags << meta_tag('OVERHEIDbm.startdatumTermijn', permit.period_start_date.utc.to_s(:w3cdtfutc), 'DCTERMS.W3CDTF') if permit.period_start_date
    tags << meta_tag('OVERHEIDbm.einddatumTermijn',  permit.period_end_date.utc.to_s(:w3cdtfutc),   'DCTERMS.W3CDTF') if permit.period_end_date
    # ==== locations ====
    permit.addresses.each do |address|
      tags << meta_tag('DCTERMS.spatial', "#{address.postal_code}#{address.house_number}", 'OVERHEID.PostcodeHuisnummer')
    end
    # ==== coordinates ====
    permit.coordinates.each do |coord|
      tags << meta_tag('DCTERMS.spatial', coord.x, 'OVERHEIDbm.x-waarde')
      tags << meta_tag('DCTERMS.spatial', coord.y, 'OVERHEIDbm.y-waarde')
    end

    tags
  end

  # Metadata that should be added to a SOLR search index
  def indexing_metadata_for(node)
    tags = []    
    tags << meta_tag('DCTERMS.alternative', node.content.product_synonyms.map(&:synonym).join(',')) if node.content_type == "Product"
    tags  
  end

  def meta_tag(name, content, scheme = nil)
    tag(:meta, :name => name, :datatype => scheme, :content => content) unless content.nil?
  end

  def node_url(node)
    if node.content_type == 'ProductCatalogue' && params[:controller] == 'products' && params[:action] == 'index'
      options = {}
      [:letter, :selection, :selection_id].each do |param|
        options[param] = params[param] if params[param].present?
      end
      product_catalogue_products_url(node.content, options)
    else
      aliased_or_delegated_url(node)
    end
  end
end
