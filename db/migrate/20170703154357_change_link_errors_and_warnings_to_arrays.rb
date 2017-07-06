class ChangeLinkErrorsAndWarningsToArrays < ActiveRecord::Migration[5.0]
  def change
    change_column_default :links, :link_warnings, nil
    change_column_default :links, :link_errors, nil
    change_column_default :local_authorities, :link_warnings, nil
    change_column_default :local_authorities, :link_errors, nil

    change_column :links, :link_warnings, "character varying[] USING array[]::character varying[]"
    change_column :links, :link_errors, "character varying[] USING array[]::character varying[]"
    change_column :local_authorities, :link_warnings, "character varying[] USING array[]::character varying[]"
    change_column :local_authorities, :link_errors, "character varying[] USING array[]::character varying[]"

    change_column_default :links, :link_warnings, []
    change_column_default :links, :link_errors, []
    change_column_default :local_authorities, :link_warnings, []
    change_column_default :local_authorities, :link_errors, []

    change_column_null :links, :link_warnings, false
    change_column_null :links, :link_errors, false
    change_column_null :local_authorities, :link_warnings, false
    change_column_null :local_authorities, :link_errors, false
  end
end
