class ChatController < WebsocketRails::BaseController
  include ActionView::Helpers::SanitizeHelper

  def initialize_session
    puts "Session Initialized\n"
  end

  def system_msg(ev, msg)
    broadcast_message ev, { 
      user_name: 'Server:', 
      received: Time.now.to_s(:time), 
      msg_body: msg
    }
  end
  
  def broadcast_user_array(event, users, msg)
    unless users.kind_of?(Array)
      a = users
      users = []
      users << a
    end
    broadcast_message event, { 
      users:  users,
      msg_body: msg
    }
  end

  def user_msg(ev, msg)
    broadcast_message ev, { 
      user_name:  connection_store[:user][:user_name], 
      received:   Time.now.to_s(:time), 
      msg_body:   ERB::Util.html_escape(msg) 
      }
  end

  def set_user_id_msg(ev, user_id)
    broadcast_message ev, { 
      user_id:  user_id
    }
  end
  
  def client_connected
    # set_user_id_msg :set_user_id, client_id
    system_msg :new_message, "Player #{client_id} connected"
  end
  
  def new_message
    user_msg :new_message, message[:msg_body].dup
  end
  
  def new_user
    connection_store[:user] = { user_name: sanitize(message[:user_name]), user_id: message[:user_id] }
    broadcast_user_list
  end
  
  def change_username
    connection_store[:user][:user_name] = sanitize(message[:user_name])
    broadcast_user_list
  end
  
  def delete_user
    game_id = connection_store[:user][:game_id]
    connection_store[:user] = nil
    system_msg :new_message, "Player #{client_id} get out :("
    broadcast_user_list
    if game_id
      game = StrategoGame.find(game_id)
      if game
        lista = []
        lista << game.player_a if game.player_a
        lista << game.player_b if game.player_b
        game.destroy
        broadcast_user_array :other_left, lista, 'Your opponent left the game'
      end
    end
  end
  
  def broadcast_user_list
    users = connection_store.collect_all(:user)
    broadcast_message :user_list, users
  end
end
