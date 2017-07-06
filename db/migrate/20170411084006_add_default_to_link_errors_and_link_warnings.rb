class AddDefaultToLinkErrorsAndLinkWarnings < ActiveRecord::Migration[5.0]
  def change
    change_column_default :links, :link_errors, {}
    change_column_default :local_authorities, :link_errors, {}
    change_column_default :links, :link_warnings, {}
    change_column_default :local_authorities, :link_warnings, {}
  end
end
