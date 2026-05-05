class CreateRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :runs do |t|
      t.string :session_token, null: false
      t.string :difficulty, null: false
      t.integer :riddle_count, null: false
      t.datetime :started_at, null: false
      t.datetime :completed_at

      t.timestamps
    end

    add_index :runs, :session_token, unique: true
  end
end
