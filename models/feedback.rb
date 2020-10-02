require 'active_record/base'

class Feedback < ActiveRecord::Base
  validates :text, presence: true, length: { maximum: 16384 }
  validates :author, length: { maximum: 512 }
  validates :sysinfo, length: { maximum: 4096 }

  scope :ordered, -> { order(created_at: :desc) }
end
