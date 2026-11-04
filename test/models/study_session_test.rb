require "test_helper"

class StudySessionTest < ActiveSupport::TestCase
  test "belongs to a topic and delegates its plan and user" do
    study_session = study_sessions(:active)

    assert_equal topics(:one), study_session.topic
    assert_equal study_plans(:one), study_session.study_plan
    assert_equal users(:one), study_session.user
  end

  test "scopes active sessions" do
    assert_equal [ study_sessions(:active), study_sessions(:other_user) ], StudySession.active.to_a
  end

  test "scopes sessions completed on a date" do
    completed_on = Date.new(2026, 10, 28)

    assert_equal [ study_sessions(:completed) ], StudySession.completed_at(completed_on).to_a
  end

  test "scopes sessions to a user" do
    assert_equal [ study_sessions(:active), study_sessions(:completed) ],
                 StudySession.of_user(users(:one)).order(:id).to_a
  end

  test "does not allow another active session for the same topic" do
    study_session = StudySession.new(topic: topics(:one), title: "Another active session")

    assert_not study_session.valid?
    assert_includes study_session.errors[:base],
                    "There is already an active study session for this topic."
  end

  test "allows a session when the topic has no active sessions" do
    study_session = StudySession.new(topic: topics(:three),
                                     title: "Another completed session",
                                     finished_at: Time.current)

    assert study_session.valid?
  end

  test "database prevents duplicate active sessions when validation is bypassed" do
    duplicate = StudySession.new(topic: topics(:one), title: "Concurrent session")

    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate.save!(validate: false)
    end
  end

  test "refreshes the cached streak before broadcasting after session changes" do
    user = users(:one)
    cache = ActiveSupport::Cache::MemoryStore.new
    study_sessions(:active).update!(started_at: Time.utc(2026, 11, 3, 10))
    study_sessions(:completed).update!(
      started_at: Time.utc(2026, 11, 2, 10),
      finished_at: Time.utc(2026, 11, 2, 11)
    )

    Rails.stub(:cache, cache) do
      travel_to Time.utc(2026, 11, 4, 12) do
        assert_equal 2, user.cached_current_study_streak
        study_sessions(:completed).update!(finished_at: Time.current)

        Turbo::StreamsChannel.stub(:broadcast_replace_to, nil) do
          study_sessions(:completed).send(:broadcast_study_streak)
        end

        assert_equal 3, user.cached_current_study_streak
      end
    end
  end
end
