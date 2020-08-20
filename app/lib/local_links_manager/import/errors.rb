module LocalLinksManager
  module Import
    module Errors
      class MissingIdentifierError < RuntimeError; end

      class MissingRecordError < RuntimeError; end
    end
  end
end
