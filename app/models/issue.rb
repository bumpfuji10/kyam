class Issue < ApplicationRecord
  enum status: { unstarted: 0, in_progress: 1, completed: 2}
  validates :title, presence: true
end
