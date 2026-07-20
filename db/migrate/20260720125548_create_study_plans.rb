class CreateStudyPlans < ActiveRecord::Migration[8.1]
  def change
    create_table :study_plans do |t|
      t.string :name, null: false
      t.text :description
      t.integer :daily_hour
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
