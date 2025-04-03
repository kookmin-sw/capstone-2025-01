class NationalAssemblyPerson < ApplicationRecord
  belongs_to :proposer

  validates :department_code, presence: true
  validates :member_id, presence: true
  validates :name, presence: true
end
