class Article < ApplicationRecord
  has_rich_text :content
  validates :title, presence: true
  has_many_attached :images do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
end
