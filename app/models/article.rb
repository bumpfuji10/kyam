class Article < ApplicationRecord
  has_rich_text :content
  validates :title, presence: true
  has_many_attached :images
end
