class NationalAssemblyPerson < ApplicationRecord
  has_many :proposals, as: :specific_proposer

  validates :department_code, presence: true
  validates :member_id, presence: true
  validates :name, presence: true
end
