WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
  #   subscribe :client_connected, :to => Controller, :with_method => :method_name
  #
  # Here is an example of mapping namespaced events:
  subscribe :client_connected, to: ChatController, with_method: :client_connected
  subscribe :client_disconnected, to: ChatController, with_method: :delete_user
  namespace :chat do
    subscribe :new_message, to: ChatController, with_method: :new_message
    subscribe :new_user, to: ChatController, with_method: :new_user
    subscribe :change_username, to: ChatController, with_method: :change_username
  end
  namespace :game do
    subscribe :put_piece, to: GameController, with_method: :put_piece
    subscribe :move_piece, to: GameController, with_method: :move_piece
    subscribe :get_in_game, to: GameController, with_method: :get_in_game
  end
  # The above will handle an event triggered on the client like `product.new`.
end
