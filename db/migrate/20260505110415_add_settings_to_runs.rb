class AddSettingsToRuns < ActiveRecord::Migration[8.1]
  def change
    add_column :runs, :audio_enabled, :boolean, null: false, default: true
    add_column :runs, :timed, :boolean, null: false, default: false
    add_column :runs, :seconds_per_puzzle, :integer, default: 30
    add_column :runs, :auto_advance, :boolean, null: false, default: true
  end
end
