class CreateTopics < ActiveRecord::Migration[8.1]
  def change
    create_table :topics do |t|
      t.string :name, null: false
      t.text :description
      t.integer :estimated_hours, null: false
      t.integer :position, null: false
      t.references :study_plan, null: false, foreign_key: true

      t.timestamps
    end
end
end
