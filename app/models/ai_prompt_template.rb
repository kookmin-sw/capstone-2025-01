class AiPromptTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :template, presence: true
end
