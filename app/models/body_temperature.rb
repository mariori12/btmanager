class BodyTemperature < ApplicationRecord
  belongs_to :user

  before_save { self.temperature = temperature.floor(1) }

  validates :user_id, presence: true
  VALID_BODY_TEMPERATURE_MIN = 35.9
  VALID_BODY_TEMPERATURE_MAX = 38.1
  validates :temperature, presence: true,
                          numericality: { greater_than_or_equal_to: VALID_BODY_TEMPERATURE_MIN,
                                          less_than_or_equal_to: VALID_BODY_TEMPERATURE_MAX }
  validates :measurement_date, presence: true, uniqueness: { scope: :user_id }

  default_scope -> { order(measurement_date: :desc) }

  def self.create_body_temperatures_array
    body_temperatures_array = [Array.new(['36.0℃未満', 35.9])]
    body_temperature_min = 360
    body_temperature_max = 380
    body_temperature_range = body_temperature_min..body_temperature_max

    body_temperature_range.each do |body_temperature|
      body_temperature /= 10.0
      body_temperatures_array.push(Array.new([body_temperature.to_s, body_temperature]))
    end
    body_temperatures_array.push(Array.new(['38.1℃以上', 38.1]))
    body_temperatures_array
  end
end
