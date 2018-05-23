class User < ApplicationRecord
  has_one :api_key

  has_many :domains, foreign_key: :creator_id
  has_many :stamps, foreign_key: :creator_id
  has_many :votes

  before_create :add_reputation

  devise :confirmable, :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable

  def voting_power
    reputation <= 0 ? 0 : reputation.log10_power
  end

  def can_vote?(votable)
    votes.today.count < daily_voting_limit && !votes.where(votable: votable).exists?
  end

  def daily_voting_limit
    ENVProxy.required_integer('USER_DAILY_VOTING_LIMIT')
  end

  def add_reputation
    self.reputation = ENVProxy.required_integer('USER_INITIAL_REPUTATION') if reputation.nil?
  end

  def top_labels(limit: 5)
    Label.joins(:stamps)
         .where(stamps: { creator_id: id })
         .group('labels.id, labels.name')
         .select('labels.name, labels.id, COUNT(labels.name)')
         .order('COUNT(labels.name) DESC, labels.name ASC')
         .limit(limit)
  end
end
