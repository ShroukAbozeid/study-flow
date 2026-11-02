class MigrateStudySessionNotesToActionText < ActiveRecord::Migration[8.1]
  include ActionView::Helpers::TextHelper

  def change
    rename_column :study_sessions, :notes, :old_notes

    StudySession.find_each do |session|
      session.notes = session.old_notes
      session.update_attribute(:notes, simple_format(session.old_notes)) # rubocop:disable Rails/SkipsModelValidations
    end
    remove_column :study_sessions, :old_notes # rubocop:disable Rails/ReversibleMigration
  end
end
