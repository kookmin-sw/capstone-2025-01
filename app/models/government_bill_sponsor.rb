# typed: true

class GovernmentBillSponsor < ApplicationRecord
  extend T::Sig

  has_many :proposals, as: :specific_proposer

  sig { returns(String) }
  def display_name
    "#{ministry_name} #{department_name} (#{manager_name})"
  end
end
