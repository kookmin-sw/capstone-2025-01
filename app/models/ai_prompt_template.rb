# frozen_string_literal: true
# typed: true

class AiPromptTemplate < ApplicationRecord
    extend T::Sig
  
    validates :name, presence: true, uniqueness: { case_sensitive: false }
    validates :template, presence: true
  
  
    sig { params(variables: T::Hash[Symbol, String]).returns(String) }
    def render_template(variables)
      template = Liquid::Template.parse(self.template)
      template.render(variables.stringify_keys)
    end
  end