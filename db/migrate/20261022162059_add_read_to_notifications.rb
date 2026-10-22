class AddReadToNotifications < ActiveRecord::Migration[8.1]
  def change
    add_column :notifications, :read, :boolean, default: false, null: false
  end
end
