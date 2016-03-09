class StrategoGame < ActiveRecord::Base
  before_create :init_board

  EMPTY = -1
  POND = -2
  END_GAME = -2

  LOST = -1
  WIN = 1
  DRAW = 0

  PIECES = {
      # :flag       => {rank: 0, name: },
      # :bomb       => {rank: 0, name: },
      # :spy        => {rank: 1, name: },
      # :scout      => {rank: 2, name: },
      # :miner      => {rank: 3, name: },
      # :sergeant   => {rank: 4, name: },
      # :lieutenant => {rank: 5, name: },
      # :captain    => {rank: 6, name: },
      # :major      => {rank: 7, name: },
      # :colonel    => {rank: 8, name: },
      # :general    => {rank: 9, name: },
      # :marshal    => {rank: 10, name: }

      :flag       => 0,
      :bomb       => 0,
      :spy        => 1,
      :scout      => 2,
      :miner      => 3,
      :sergeant   => 4,
      :lieutenant => 5,
      :captain    => 6,
      :major      => 7,
      :colonel    => 8,
      :general    => 9,
      :marshal    => 10
    }

  def init_board
    _board = []
    10.times {_board << Array.new(10, EMPTY)}

    # lago
    # [4, 5].each do |lin|
    #   [2, 3].each { |col| _board[lin][col] = POND }

    #   [6, 7].each { |col| _board[lin][col] = POND }
    # end
    _board[4][2] = POND
    _board[4][3] = POND
    _board[5][2] = POND
    _board[5][3] = POND

    _board[4][6] = POND
    _board[4][7] = POND
    _board[5][6] = POND
    _board[5][7] = POND

    self.board = _board

    _npa = [1, 6, 1, 8, 5, 4, 4, 4, 3, 2, 1, 1]

    self.player_a_max_p = ActiveSupport::JSON.encode _npa
    self.player_b_max_p = ActiveSupport::JSON.encode _npa

  end

  def set_pieces_out(player, pieces)
    if player_a == player.to_s
      self.player_a_max_p = ActiveSupport::JSON.encode pieces
    elsif player_b == player.to_s
      self.player_b_max_p = ActiveSupport::JSON.encode pieces
    end
  end

  def num_pieces_out(player)
    if player_a == player.to_s
      res = ActiveSupport::JSON.decode player_a_max_p
    elsif player_b == player.to_s
      res = ActiveSupport::JSON.decode player_b_max_p
    end
  end

  def retirar_peca_fora(player, piece)
    pieces_out = num_pieces_out player
    if pieces_out[piece] > 0
      pieces_out[piece] -= 1

      self.set_pieces_out player, pieces_out

      return pieces_out[piece]
    end

    return false
  end

  def put_piece_tab(player, pos, piece)
    piece = piece.to_i
    pos = pos.split('x').collect {|s| s.to_i}
    if player_a == player.to_s
      pos[0] = 9 - pos[0]
      pos[1] = 9 - pos[1]
    end

    _board = self.board
    
    return false if _board[pos[0]][pos[1]] == POND
    
    resto = retirar_peca_fora(player, piece)
    
    return false if resto == false
    
    _board[pos[0]][pos[1]] = {player: player, piece_index: piece}
    self.board= _board

    pos[0].to_s+'x'+pos[1].to_s
  end

  def check_order_pos(player, pos_ini, pos_fim)
    if player == player_a
      pos_ini[0] = 9 - pos_ini[0]
      pos_ini[1] = 9 - pos_ini[1]
      pos_fim[0] = 9 - pos_fim[0]
      pos_fim[1] = 9 - pos_fim[1]
    end
  end

  def move_piece(player, pos_ini, pos_fim)
    p_ini = pos_ini.split('x').collect {|s| s.to_i}
    p_fim = pos_fim.split('x').collect {|s| s.to_i}

    check_order_pos player, p_ini, p_fim
    
    _my_board = self.board
    
    # _my_board.each {|e| puts e.to_s}
    
    lugar_a = _my_board[p_ini[0]][p_ini[1]]
    lugar_b = _my_board[p_fim[0]][p_fim[1]]

    if lugar_a['player'] != player
      aux = lugar_a
      lugar_a = lugar_b
      lugar_b = aux

      aux = p_ini
      p_ini = p_fim
      p_ini = aux
    end


    if lugar_b == EMPTY
      _my_board[p_fim[0]][p_fim[1]] = lugar_a
      _my_board[p_ini[0]][p_ini[1]] = EMPTY
      self.board= _my_board

      check_order_pos player, p_ini, p_fim
      
      return {cod: 2, jog: player, peca_pos: p_ini, peca_pos_fim: p_fim}
    end

    piece_a = lugar_a['piece_index']
    piece_b = lugar_b['piece_index']
    res = attack(piece_a, piece_b)

    return res if res == END_GAME

    if res == WIN
      _my_board[p_fim[0]][p_fim[1]] = EMPTY
    elsif res == LOST
      _my_board[p_ini[0]][p_ini[1]] = EMPTY
    else
      _my_board[p_fim[0]][p_fim[1]] = EMPTY
      _my_board[p_ini[0]][p_ini[1]] = EMPTY
    end
    self.board= _my_board

    check_order_pos player, p_ini, p_fim

    {cod: res, jog: player, peca_pos: p_ini, peca: piece_a, peca_adv: piece_b, peca_adv_pos: p_fim}
  end

  def board
    ActiveSupport::JSON.decode self.board_as_json
  end

  def board=(json)
    self.board_as_json = ActiveSupport::JSON.encode json 
  end

  ## add a new player to the game.
  ## see get_in_game in controller
  def add_player(player)
    if !player_a.present?
      self.player_a = player
    elsif !player_b.present?
      self.player_b = player
      self.who_played_last = player
    else
      return false
    end
  end

  def ready?
    player_b.present? and player_a.present?
  end

  def players
    if ready?
      list = []
      list << player_a
      list << player_b
      list
    end
  end

  def outro_jogador(jogador)    
    if player_a == jogador.to_s
      self.player_b
    elsif player_b == jogador.to_s
      self.player_a
    end
  end

  def ready_to_go?
    c = 0
    c1 = 0
    tab = self.board
    0.upto(3) do |i|
      tab[i].each do |val|
        if val != EMPTY
          c += 1
        end
      end
    end

    6.upto(9) do |i|
      tab[i].each do |val|
        if val != EMPTY
          c1 += 1
        end
      end
    end

    return (c == 40 and c1 == 40)
  end

  def attack(piece1_index, piece2_index)
    p1_name = PIECES.keys[piece1_index]
    p2_name = PIECES.keys[piece2_index]

    return WIN if p1_name == :miner and p2_name == :bomb

    return LOST if p2_name == :bomb

    return END_GAME if p2_name == :flag

    return WIN if p1_name == :spy and p2_name == :marshal

    if PIECES[p1_name] > PIECES[p2_name]
      return WIN
    elsif PIECES[p1_name] < PIECES[p2_name]
      return LOST
    elsif PIECES[p1_name] == PIECES[p2_name]
      return DRAW
    end

  end
end
