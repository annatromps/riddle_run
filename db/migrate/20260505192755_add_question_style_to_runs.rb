class AddQuestionStyleToRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :runs, :question_style, :string, null: false, default: "word_puzzles"
  end
end
