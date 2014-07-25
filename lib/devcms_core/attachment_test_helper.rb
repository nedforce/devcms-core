module DevcmsCore
  module AttachmentTestHelper
    # Load a file into the db as LO and return the OID
    # def load_file(name)
    #   conn = ActiveRecord::Base.connection.raw_connection
    #   conn.exec "BEGIN"
    #   loid = conn.lo_import(File.dirname(__FILE__)+"/../test/fixtures/#{name}")
    #   conn.exec "COMMIT"
    #   return loid
    # end

    # Converts a binary file to YAML for use in test fixtures. The name is
    # relative to the test/fixtures directory.
    def fixture_data(name)
      binary_to_yaml(File.dirname(__FILE__)+"/../../test/fixtures/#{name}")
    end

    # Converts a binary file to YAML for use in test fixtures.
    def binary_to_yaml(filename)
      data = File.open(filename,'rb').read
      "!binary | #{[data].pack('m').gsub(/\n/, "\n   ")}\n"
    end
  end
end
