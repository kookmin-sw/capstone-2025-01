class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class


  # 모든 ActiveRecord 모델에서 Ransack 기본값 적용
  # https://www.rubydoc.info/gems/ransack/Ransack%2FAdapters%2FActiveRecord%2FBase:authorizable_ransackable_attributes
  def self.ransackable_attributes(_auth_object = nil) = authorizable_ransackable_attributes
  # https://www.rubydoc.info/gems/ransack/Ransack%2FAdapters%2FActiveRecord%2FBase:authorizable_ransackable_associations
  def self.ransackable_associations(_auth_object = nil) = authorizable_ransackable_associations
end
