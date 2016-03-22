class DataMigrationGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  source_root File.expand_path("../templates", __FILE__)

  def self.next_migration_number(_path)
    Time.zone.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_data_migration_file
    template = Rails.root.join("db/data_migration", "#{file_name}.rb")
    migration_template("data_migration.rb", template)
  end
end
