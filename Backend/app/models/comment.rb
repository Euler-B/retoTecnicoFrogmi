class Comment < ApplicationRecord
  belongs_to :sismo

  validates :body, presence: true
end
