require 'active_record/base'

class Feedback < ActiveRecord::Base
  validates :text, presence: true, length: { maximum: 32768 }
  validates :author, length: { maximum: 256 }
  validates :sysinfo, length: { maximum: 4096 }

  scope :ordered, -> { order(created_at: :desc) }

  def to_s
    author.empty? ? text : "#{author}: #{text}"
  end
end
