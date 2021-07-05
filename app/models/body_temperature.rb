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

  default_scope -> { order(user_id: :asc, measurement_date: :desc) }

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

  def self.convert_body_temperature_display(body_temperature)
    return if body_temperature.blank?

    body_temperature_min = 36
    body_temperature_max = 38.1
    if body_temperature >= body_temperature_max
      '38.1℃以上'
    elsif body_temperature < body_temperature_min
      '36.0℃未満'
    else
      "#{body_temperature}℃"
    end
  end

  def self.create_body_temperatures_hash_of_user(date_range)
    return if date_range.blank?

    body_temperatures = where(measurement_date: date_range)

    body_temperatures.each_with_object({}) do |body_temperature, hash|
      hash[body_temperature.user_id] = {} if hash[body_temperature.user_id].nil?
      hash[body_temperature.user_id][body_temperature.measurement_date.day] = body_temperature.temperature
    end
  end
end
