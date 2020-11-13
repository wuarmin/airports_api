module InputTypes
  class GeoPosition < InputTypes::BaseInputObject
    description "latitude and longitude"
    argument :latitude, Float, required: true
    argument :longitude, Float, required: true
    argument :radius, Integer, required: false, default_value: nil
  end
end
