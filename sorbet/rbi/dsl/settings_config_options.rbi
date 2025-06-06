# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `SettingsConfigOptions`.
# Please instead update this file by running `bin/tapioca dsl SettingsConfigOptions`.


Settings = T.let(T.unsafe(nil), SettingsConfigOptions)

class SettingsConfigOptions < ::Config::Options
  extend T::Generic

  Elem = type_member { { fixed: T.untyped } }

  sig { returns(T.untyped) }
  def bill_category; end

  sig { params(value: T.untyped).returns(T.untyped) }
  def bill_category=(value); end

  sig { returns(T.untyped) }
  def bill_summary; end

  sig { params(value: T.untyped).returns(T.untyped) }
  def bill_summary=(value); end

  sig { returns(T.untyped) }
  def bills; end

  sig { params(value: T.untyped).returns(T.untyped) }
  def bills=(value); end

  sig { returns(T.untyped) }
  def litellm; end

  sig { params(value: T.untyped).returns(T.untyped) }
  def litellm=(value); end
end
