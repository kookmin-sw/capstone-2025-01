class Proposer < ApplicationRecord
  has_many :proposals
  has_many :bills, through: :proposals
  has_one :national_assembly_person
  has_one :government_bill_sponsor

  validates :proposer_type, presence: true, inclusion: { in: %w[의원 위원장 정부 의장 대통령 기타] }
end
