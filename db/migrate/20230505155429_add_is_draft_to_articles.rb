class AddIsDraftToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :is_draft, :boolean, default: false, null: false
  end
end
