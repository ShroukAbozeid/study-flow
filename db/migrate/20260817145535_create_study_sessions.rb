class CreateStudySessions < ActiveRecord::Migration[8.1]
  def change
    create_table :study_sessions do |t|
      t.string :title, null: false
      t.datetime :started_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :finished_at
      t.text :notes
      t.references :topic, null: false, foreign_key: true

      t.timestamps
    end
  end
end
