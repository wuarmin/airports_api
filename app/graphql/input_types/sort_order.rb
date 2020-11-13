require_relative './base_enum'

class Types::SortOrder < Types::BaseEnum
  value "DESCENDING", value: :desc
  value "ASCENDING", value: :asc
end
