module Models
  class Airport < Sequel::Model(DB[Sequel[:public][:airports]])
  end
end

