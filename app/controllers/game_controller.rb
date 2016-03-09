class GameController < ChatController

  def initialize_session
    puts "Session Initialized\n"
  end

  def get_in_game
    if connection_store[:user][:game_id]
      id = connection_store[:user][:game_id]
      game = StrategoGame.find id
    end

    if game
      broadcast_user_array :alert, connection_store[:user][:user_id], 'Game started'
    else
      game = StrategoGame.where('player_a is null or player_b is null').first
      
      game ||= StrategoGame.new

      game.add_player connection_store[:user][:user_id]

      if game.save
        connection_store[:user][:game_id] = game.id
        if game.ready?
          broadcast_user_array :start_game, game.players, 'Game started'
        else
          broadcast_user_array :waiting, connection_store[:user][:user_id], 'Waiting opponent..'
        end
      else
        system_msg :log, game.errors.inspect
      end
    end
    
  end

  def put_piece
    if connection_store[:user][:game_id].present?
      position = message[:pos]
      peca_id = message[:peca]
      game = StrategoGame.find connection_store[:user][:game_id]
      if game
        jog = connection_store[:user][:user_id]
        res = game.put_piece_tab jog, position, peca_id
        if res != false
          broadcast_user_array :put_piece_ad, game.outro_jogador(jog), pos_r(position)
        end
        game.save
        broadcast_user_array :num_pieces_out, jog, game.num_pieces_out(jog)
        if game.ready_to_go?
          broadcast_user_array :start_new_turn, game.players, {ultimo: game.who_played_last}
        end
      end
    end
  end

  def move_piece
    if connection_store[:user][:game_id].present?
      pos_ini = message[:pos_ini]
      pos_fim = message[:pos_fim]
      game = StrategoGame.find connection_store[:user][:game_id]
      if game
        jog = connection_store[:user][:user_id]
        if jog != game.who_played_last
          res = game.move_piece jog, pos_ini, pos_fim
          if res == StrategoGame::END_GAME
            broadcast_user_array :end_game, game.players, jog
          else
            game.who_played_last = jog
            res[:ultimo] = game.who_played_last
            broadcast_user_array :update_game, game.players, res
          end
          game.save
        end
      end
    end
  end

  def pos_r pos
    pos = pos.split('x')
    pos[0] = 9 - pos[0].to_i
    pos[1] = 9 - pos[1].to_i

    pos[0].to_s+'x'+pos[1].to_s
  end
end
