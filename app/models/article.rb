class Article < ApplicationRecord
  has_rich_text :content
  validates :title, presence: true
  # validate :not_before_now
  has_many_attached :images do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end

  def published?
    return true if is_published == true && post_reservation_date.nil?
  end

  # TODO: 日付に対するカスタムバリデーションを作成する
  # def not_before_now
  #   if post_reservation_date.present?
  #     if post_reservation_date <= Time.now
  #       errors.add(:post_reservation_date, "は過去の日時で指定できません")
  #     end
  #   end
  # end
end
