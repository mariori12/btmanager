class Admin::ExportBodyTemperaturesController < ApplicationController
  before_action :require_admin

  def index
    @selected_search_measurement_date_start = format_search_measurement_date_start
    return if @selected_search_measurement_date_start.blank?

    @body_temperatures = get_body_temperatures(@selected_search_measurement_date_start).page(params[:page])
    flash.now[:alert] = '該当データが存在しません。' if @body_temperatures.blank?
  end

  def export
    users = User.all
    day_names = t('date.abbr_day_names')
    start_date = params[:selected_search_measurement_date_start].try(:to_date)
    end_date = start_date.try(:end_of_month)
    date_range = start_date..end_date
    body_temperatures_hash = BodyTemperature.create_body_temperatures_hash_of_user(date_range)
    respond_to do |format|
      format.csv do
        export_body_temperatures_csv(users, day_names, date_range, body_temperatures_hash)
      end
    end
  end

  private

  def get_body_temperatures(search_measurement_date_start)
    return if search_measurement_date_start.blank?

    search_measurement_date_end = search_measurement_date_start.end_of_month
    BodyTemperature.where(measurement_date: search_measurement_date_start..search_measurement_date_end)
  end

  def format_search_measurement_date_start
    year = params[:'search_measurement_date(1i)']
    month = params[:'search_measurement_date(2i)']
    day = params[:'search_measurement_date(3i)']

    Date.new year.to_i, month.to_i, day.to_i if year.present? && month.present? && day.present?
  end

  def export_body_temperatures_csv(users, day_names, date_range, body_temperatures_hash)
    return if users.blank? || body_temperatures_hash.blank? || date_range.blank?

    send_data NKF.nkf(
      '-Lw --ic=UTF-8 --oc=CP932', csv_data(users, day_names, date_range, body_temperatures_hash)
    ), filename: 'body_temperatures.csv', type: 'text/csv; charset=CP932;'
  end

  def csv_data(users, day_names, date_range, body_temperatures_hash)
    CSV.generate do |csv|
      csv << csv_header(users)

      date_range.each do |day|
        csv << csv_value(users, day_names, day, body_temperatures_hash)
      end
    end
  end

  def csv_header(users)
    users.each_with_object(['', '']) { |user, csv_column_header| csv_column_header << user.name }
  end

  def csv_value(users, day_names, day, body_temperatures_hash)
    csv_column_value = []
    csv_column_value << l(day, format: :month_day) << "(#{day_names[day.wday]})"
    users.each do |user|
      body_temperature = body_temperatures_hash.dig(user.id, day.mday)
      csv_column_value << BodyTemperature.convert_body_temperature_display(body_temperature)
    end
    csv_column_value
  end
end
