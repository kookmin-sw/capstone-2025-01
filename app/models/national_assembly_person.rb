# typed: true

class NationalAssemblyPerson < ApplicationRecord
  extend T::Sig

  has_many :proposals, as: :specific_proposer

  validates :department_code, presence: true
  validates :member_id, presence: true
  validates :name, presence: true

  sig { returns(String) }
  def display_name
    name
  end
end
