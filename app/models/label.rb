class Label < ApplicationRecord
  belongs_to :licence
  belongs_to :parent, class_name: 'Label', optional: true

  has_many :stamps
  has_many :children, class_name: 'Label', foreign_key: :parent_id

  jsonb_accessor :config, binary: [:boolean, default: false], steps: [:integer, default: 5]

  # TODO
  def top_contributors
    User.joins(:stamps)
        .select('stamps.creator_id, COUNT(stamps.creator_id)')
        .where(stamps: { label_id: id })
        .group('stamps.creator_id')
        .order('COUNT(stamps.creator_id) DESC')
        .limit(5)
  end

  def stamps_in_progress
    stamps.in_progress.order(percentage: :desc).limit(5)
  end

  def stamps_including_child_labels
    Stamp.where(label_id: [id, children.select(:id)].flatten)
  end
end
