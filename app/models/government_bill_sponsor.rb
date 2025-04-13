# typed: true

class GovernmentBillSponsor < ApplicationRecord
  extend T::Sig

  has_many :proposals, as: :specific_proposer

  sig { returns(String) }
  def display_name
    "#{ministry_name}"
  end
end
