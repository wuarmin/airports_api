module Models
  class Airport < Sequel::Model(DB[Sequel[:public][:airports]])
    dataset_module do
    end
  end
end

