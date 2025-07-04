class CreateArchives < ActiveRecord::Migration
  def self.up
    create_table :archives do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :archives
  end
end
