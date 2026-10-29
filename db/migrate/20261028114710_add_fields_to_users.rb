class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    change_table :users, bulk: true do |t|
      t.string  :name
      t.string  :time_zone, default: 'UTC'
    end
  end
end
