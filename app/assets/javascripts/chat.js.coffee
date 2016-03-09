# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
window.Chat = {}

getCookie = (cname) =>
  name = cname + "="
  ca = document.cookie.split(';')
  for ic of ca
    c = ca[ic]
    while (c.charAt(0)==' ') 
      c = c.substring(1)
    if c.indexOf(name) == 0
      return c.substring(name.length, c.length)
  return null;

class Chat.User
  constructor: (@user_name, @user_id) ->
  serialize: => { user_id: @user_id, user_name: @user_name }

class Chat.Controller
  template: (message) ->
    html =
      """
      <div class="message" >
        <label class="label label-info">
          [#{message.received}] #{message.user_name}
        </label>&nbsp;
        #{message.msg_body}
      </div>
      """
    $(html)

  userListTemplate: (userList) ->
    userHtml = ""
    ativo = $('.userlist.active').find('[data-token]').data('token')
    for user in userList
      userHtml = userHtml + '<li class="userlist"><a href="#" data-token="'+user.user_id+'"><i class="i"></i>'+user.user_name+'</a></li>'

    $(userHtml).each ->
      if ativo and $(this).find('[data-token]').data('token') == ativo
        $(this).addClass('active')
      $(this).click ->
        $('.userlist').each ->
          $(this).removeClass('active')

        $(this).addClass('active')
        false

  constructor: (url, useWebSockets) ->
    @messageQueue = []
    @dispatcher = new WebSocketRails(url,useWebSockets)
    @dispatcher.on_open = @createGuestUser
    @bindEvents()

  bindEvents: =>
    @dispatcher.bind 'log', @log
    @dispatcher.bind 'new_message', @newMessage
    @dispatcher.bind 'user_list', @updateUserList
    $('input#user_name').on 'keyup', @updateUserInfo
    $('#send').on 'click', @sendMessage
    $('#message').keypress (e) -> $('#send').click() if e.keyCode == 13

  log: (m) =>
    console.log m
  
  newMessage: (message) =>
    @messageQueue.push message
    @shiftMessageQueue() if @messageQueue.length > 15
    @appendMessage message

  sendMessage: (event) =>
    event.preventDefault()
    message = $('#message').val()
    if message.trim().length > 0
      @dispatcher.trigger 'chat.new_message', {user_name: @user.user_name, msg_body: message}
      $('#message').val('')

  updateUserList: (userList) =>
    $('#user-list').html @userListTemplate(userList)

  updateUserInfo: (event) =>
    @user.user_name = $('input#user_name').val()
    $('#username').html @user.user_name
    @dispatcher.trigger 'chat.change_username', @user.serialize()

  appendMessage: (message) ->
    messageTemplate = @template(message)
    $('#chat').append messageTemplate
    messageTemplate.slideDown 140
    $('.chat-div').scrollTop($('#chat')[0].scrollHeight)

  shiftMessageQueue: =>
    @messageQueue.shift()
    $('#chat div.messages:first').slideDown 100, ->
      $(this).remove()

  deleteUser: =>
    @dispatcher.trigger 'chat.client_disconnected', @user.serialize()

  createGuestUser: (data) =>
    id = data.connection_id
    rand_num = Math.floor(Math.random()*1000)
    @user = new Chat.User("Player_" + rand_num, id)
    $('#username').html @user.user_name
    $('input#user_name').val @user.user_name
    @dispatcher.trigger 'chat.new_user', @user.serialize()