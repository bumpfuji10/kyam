class AddIsPublishedToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :is_published, :boolean, default: true, null: false
  end
end
