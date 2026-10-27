class MigrateStudySessionNotesToActionText < ActiveRecord::Migration[8.1]
  include ActionView::Helpers::TextHelper

  def change
    rename_column :study_sessions, :notes, :old_notes

    StudySession.all.each do |session|
      session.notes = session.old_notes
      session.update_attribute(:notes, simple_format(session.old_notes))
    end
    remove_column :study_sessions, :old_notes
  end
end
