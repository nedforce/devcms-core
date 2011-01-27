CVDR_CONFIG = {}
CVDR_CONFIG[:wsdl] = "#{CVDR_CONFIG[:endpoint]}?WSDL"
CVDR_CONFIG[:xpath] = { 
    :identifier => '//cvdr:meta/cvdr:owmskern/dcterms:identifier', 
    :title => '//cvdr:meta/cvdr:owmskern/dcterms:title', 
    :modified => '//cvdr:meta/cvdr:owmskern/dcterms:modified', 
    :issued => '//cvdr:meta/cvdr:owmsmantel/dcterms:issued', 
    :cite_title => '//cvdr:meta/cvdr:owmsmantel/dcterms:alternative',     
    :subject => '//cvdr:meta/cvdr:owmsmantel/dcterms:subject', 
    :body => '//cvdr:regeling' 
  }
CVDR_CONFIG[:namespace] = 'cvdr:http://standaarden.overheid.nl/cvdr/terms/'

