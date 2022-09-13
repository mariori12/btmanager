class Admin::ExportAndImportCsvController < ApplicationController
  before_action :require_admin

  def index; end

  def export
    respond_to do |format|
      format.csv do
        case params[:table_name]
        when 'users'
          send_data User.export_csv, filename: 'users.csv', type: 'text/csv;'
        when 'body_temperatures'
          send_data BodyTemperature.export_csv, filename: 'body_temperatures.csv', type: 'text/csv;'
        end
      end
    end
  end

  def import
    return redirect_to admin_export_and_import_csv_url unless params[:file]

    options = case file_basename
              when 'users.csv'
                User.import_csv(params[:file])
                { notice: 'ユーザデータを入力しました。' }
              when 'body_temperatures.csv'
                BodyTemperature.import_csv(params[:file])
                { notice: '体温データを入力しました。' }
              else
                { alert: 'CSVファイル名を確認してください。' }
              end
    redirect_to admin_export_and_import_csv_url, options
  end

  private

  def file_basename
    File.basename(params[:file]&.original_filename)
  end
end
