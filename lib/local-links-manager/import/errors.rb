module LocalLinksManager
  module Import
    class MissingIdentifierError < RuntimeError; end

    class MissingRecordError < RuntimeError; end

    class UrlValidationException < RuntimeError; end
  end
end
