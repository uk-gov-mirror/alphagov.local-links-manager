class AddActiveEndDateAndActiveNoteToLocalAuthority < ActiveRecord::Migration[7.0]
  def change
    change_table :local_authorities, bulk: true do |t|
      t.datetime :active_end_date, null: true, default: nil
      t.string :active_note
    end
  end
end
