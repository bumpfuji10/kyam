class AddIsPublishedToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :is_published, :boolean, default: false, null: false
  end
end
