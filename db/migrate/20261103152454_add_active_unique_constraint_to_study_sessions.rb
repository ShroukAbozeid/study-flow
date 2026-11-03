class AddActiveUniqueConstraintToStudySessions < ActiveRecord::Migration[8.1]
  def change
    add_index :study_sessions, [ :topic_id ], unique: true, where: "finished_at IS NULL", name: "index_study_sessions_on_topic_id_active"
  end
end
