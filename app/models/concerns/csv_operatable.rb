module CsvOperatable
  extend ActiveSupport::Concern

  # includeしたモデルに対してCSVエクスポート/インポートの機能を追加する。

  class_methods do
    def export_csv
      CSV.generate(headers: true) do |csv|
        csv << attribute_names
        all.find_each do |data|
          csv << data.attributes.values
        end
      end
    end

    def import_csv(file_path)
      File.open(file_path) do |f|
        CSV.new(f, headers: true).each do |row|
          object = find_by(id: row['id']) || new(id: row['id'])
          object.attributes = row.to_h
          object.save!
        end
      end
      sql = <<~SQL.squish
        SELECT setval('#{table_name}_id_seq', coalesce((SELECT MAX(id)+1 FROM #{table_name}), 1), false)
      SQL
      ActiveRecord::Base.connection.execute(sql)
    end
  end
end
