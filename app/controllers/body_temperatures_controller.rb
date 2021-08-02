class BodyTemperaturesController < ApplicationController
  before_action :login_required

  def index
    @user = identify_user_information
    @selected_search_measurement_date_start = format_search_measurement_date_start
    @body_temperatures = get_body_temperatures(@user, @selected_search_measurement_date_start).page(params[:page])
    flash.now[:alert] = '該当データが存在しません。' if @selected_search_measurement_date_start.present? && @body_temperatures.blank?
  end

  def create
    @user = identify_user_information
    @body_temperature = @user.body_temperatures.build(body_temperature_params)

    if @body_temperature.save
      redirect_to body_temperature_url(@body_temperature),
                  notice: "「#{l(@body_temperature.measurement_date, format: :default)}」の体温を登録しました。"
    else
      render :new
    end
  end

  def new
    @user = identify_user_information
    @body_temperature = BodyTemperature.new
  end

  def edit
    @user = identify_user_information
    @body_temperature = BodyTemperature.find(params[:id])
  end

  def show
    @body_temperature = BodyTemperature.find(params[:id])
  end

  def update
    @user = identify_user_information
    @body_temperature = BodyTemperature.find(params[:id])

    if @body_temperature.update(body_temperature_params)
      redirect_to body_temperature_url(@body_temperature),
                  notice: "「#{l(@body_temperature.measurement_date, format: :default)}」の体温を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    body_temperature = BodyTemperature.find(params[:id])
    body_temperature.destroy
    redirect_to body_temperatures_url(user_id: body_temperature.user.id),
                notice: "「#{l(body_temperature.measurement_date, format: :default)}」の体温を削除しました。"
  end

  private

  def body_temperature_params
    params.require(:body_temperature).permit(:measurement_date, :temperature, :user_id)
  end

  def identify_user_information
    if params[:user_id] && current_user.admin?
      User.find(params[:user_id])
    else
      current_user
    end
  end

  def get_body_temperatures(user, search_measurement_date_start)
    if search_measurement_date_start.present?
      search_measurement_date_end = search_measurement_date_start.end_of_month
      user.body_temperatures.where(measurement_date: search_measurement_date_start..search_measurement_date_end)
    else
      user.body_temperatures
    end
  end

  def format_search_measurement_date_start
    year = params[:'search_measurement_date(1i)']
    month = params[:'search_measurement_date(2i)']

    Date.new(year.to_i, month.to_i).beginning_of_month if year.present? && month.present?
  end
end
