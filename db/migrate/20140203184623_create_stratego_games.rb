class CreateStrategoGames < ActiveRecord::Migration
  def change
    create_table :stratego_games do |t|
      t.string :player_a
      t.string :player_b

      t.string :player_a_max_p
      t.string :player_b_max_p

      t.string :who_played_last
      
      t.text :board_as_json

      t.timestamps
    end
  end
end
