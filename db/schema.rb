# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_05_192755) do
  create_table "attempts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "outcome"
    t.integer "position", null: false
    t.integer "riddle_id", null: false
    t.integer "run_id", null: false
    t.integer "time_taken_seconds"
    t.datetime "updated_at", null: false
    t.index ["riddle_id"], name: "index_attempts_on_riddle_id"
    t.index ["run_id"], name: "index_attempts_on_run_id"
  end

  create_table "riddles", force: :cascade do |t|
    t.string "answer", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.string "difficulty", null: false
    t.text "hint"
    t.boolean "published", default: false, null: false
    t.text "question", null: false
    t.integer "thinking_seconds", default: 30, null: false
    t.datetime "updated_at", null: false
  end

  create_table "runs", force: :cascade do |t|
    t.boolean "audio_enabled", default: true, null: false
    t.boolean "auto_advance", default: true, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "difficulty", null: false
    t.string "question_style", default: "word_puzzles", null: false
    t.integer "riddle_count", null: false
    t.integer "seconds_per_puzzle", default: 30
    t.string "session_token", null: false
    t.datetime "started_at", null: false
    t.boolean "timed", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["session_token"], name: "index_runs_on_session_token", unique: true
  end

  add_foreign_key "attempts", "riddles"
  add_foreign_key "attempts", "runs"
end
