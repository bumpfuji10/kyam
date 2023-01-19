class CreateIssues < ActiveRecord::Migration[6.1]
  def change
    create_table :issues do |t|
      t.string :title, null: false
      t.text :content
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
