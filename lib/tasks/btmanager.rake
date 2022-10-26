require 'csv'

EXPORT_AND_IMPORT_INFO = [
  { class_name: 'User', file_name: 'users.csv' },
  { class_name: 'BodyTemperature', file_name: 'body_temperatures.csv' }
].freeze

namespace :btmanager do
  desc 'データベースをエクスポートする'
  task export: :environment do
    Rails.logger.info 'Start database export.'

    EXPORT_AND_IMPORT_INFO.each do |export_info|
      File.open(export_info[:file_name], 'w') do |f|
        f.write(export_info[:class_name].constantize.export_csv)
      end
    end

    Rails.logger.info 'End database export.'
  end

  desc 'データベースをインポートする'
  task import: :environment do
    Rails.logger.info 'Start database import.'

    EXPORT_AND_IMPORT_INFO.each do |import_info|
      next unless File.exist?(import_info[:file_name])

      import_info[:class_name].constantize.import_csv(import_info[:file_name])
    end

    Rails.logger.info 'End database import.'
  end
end
