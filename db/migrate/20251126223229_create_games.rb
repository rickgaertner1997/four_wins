class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.json :board
      t.integer :current_player
      t.integer :winner
      t.integer :moves_count

      t.timestamps
    end
  end
end
