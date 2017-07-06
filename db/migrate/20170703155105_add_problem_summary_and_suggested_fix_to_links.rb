class AddProblemSummaryAndSuggestedFixToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :problem_summary, :string
    add_column :links, :suggested_fix, :string

    add_column :local_authorities, :problem_summary, :string
    add_column :local_authorities, :suggested_fix, :string
  end
end
