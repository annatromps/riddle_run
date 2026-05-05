class CreateRiddles < ActiveRecord::Migration[8.1]
  def change
    create_table :riddles do |t|
      t.text :question, null: false
      t.string :answer, null: false
      t.text :hint
      t.string :difficulty, null: false
      t.string :category
      t.integer :thinking_seconds, null: false, default: 30
      t.boolean :published, null: false, default: false

      t.timestamps
    end
  end
end
