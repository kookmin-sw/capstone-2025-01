class Department < ApplicationRecord
  has_many :bills, dependent: :nullify
end
