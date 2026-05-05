class CreateAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :attempts do |t|
      t.references :run, null: false, foreign_key: true
      t.references :riddle, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :outcome
      t.integer :time_taken_seconds

      t.timestamps
    end
  end
end
