class Note < ApplicationRecord
  belongs_to :user
  has_many :shared_notes, :dependent => :destroy

  validates :title, :description, presence: true
end
