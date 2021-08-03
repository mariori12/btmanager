class BodyTemperature < ApplicationRecord
  belongs_to :user

  before_save :temperature_rounddown

  BODY_TEMPERATURE_RANGE = { min: 35.9, max: 38.1 }.freeze
  validates :temperature,
            numericality: {
              message: :invalid,
              greater_than_or_equal_to: BODY_TEMPERATURE_RANGE[:min],
              less_than_or_equal_to: BODY_TEMPERATURE_RANGE[:max]
            }
  validates :measurement_date, presence: true
  validates :measurement_date, uniqueness: { scope: :user_id }

  scope :sorted, -> { order(user_id: :asc, measurement_date: :desc) }
  scope :search_with_measurement_date, lambda { |measurement_date_range|
    where(measurement_date: measurement_date_range).sorted
  }

  BODY_TEMPERATURE_STEP = 0.1
  BODY_TEMPERATURE_OFFSET = 10.0
  ARRAY_COUNT_START = ((BODY_TEMPERATURE_RANGE[:min] + BODY_TEMPERATURE_STEP) * BODY_TEMPERATURE_OFFSET).to_i
  ARRAY_COUNT_END = ((BODY_TEMPERATURE_RANGE[:max] - BODY_TEMPERATURE_STEP) * BODY_TEMPERATURE_OFFSET).to_i
  ARRAY_COUNT_RANGE = (ARRAY_COUNT_START..ARRAY_COUNT_END).freeze
  def self.create_body_temperatures_array
    body_temperatures_array = [Array.new(
      ["#{BODY_TEMPERATURE_RANGE[:min] + BODY_TEMPERATURE_STEP}℃未満", BODY_TEMPERATURE_RANGE[:min]]
    )]

    ARRAY_COUNT_RANGE.each do |array_count|
      body_temperature = array_count / BODY_TEMPERATURE_OFFSET
      body_temperatures_array.push(Array.new([body_temperature.to_s, body_temperature]))
    end
    body_temperatures_array.push(Array.new(["#{BODY_TEMPERATURE_RANGE[:max]}℃以上", BODY_TEMPERATURE_RANGE[:max]]))
    body_temperatures_array
  end

  def self.convert_body_temperature_display(body_temperature)
    return if body_temperature.blank?

    if body_temperature >= BODY_TEMPERATURE_RANGE[:max]
      "#{BODY_TEMPERATURE_RANGE[:max]}℃以上"
    elsif body_temperature <= BODY_TEMPERATURE_RANGE[:min]
      "#{BODY_TEMPERATURE_RANGE[:min] + BODY_TEMPERATURE_STEP}℃未満"
    else
      "#{body_temperature}℃"
    end
  end

  def self.create_body_temperatures_hash_of_user(date_range)
    return if date_range.blank?

    body_temperatures = search_with_measurement_date(date_range)

    body_temperatures.each_with_object({}) do |body_temperature, hash|
      hash[body_temperature.user_id] = {} if hash[body_temperature.user_id].nil?
      hash[body_temperature.user_id][body_temperature.measurement_date.day] = body_temperature.temperature
    end
  end

  private

  def temperature_rounddown
    self.temperature = temperature.floor(1)
  end
end
