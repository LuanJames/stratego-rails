# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  window.chatController = new Chat.Controller($('#chat').data('uri'), true);
  window.gameController = new Game.Controller($('#chat').data('uri'), true);

  $('#user_info_get_out').click ->
    document.cookie = 'combate_id='
    location.reload()

window.Game = {}

# class Game.User
#   constructor: (@user_name) ->
#   serialize: => { user_name: @user_name }

class Game.Controller
  constructor: (url,useWebSockets) ->
    @messageQueue = []
    @dispatcher = window.chatController.dispatcher
    @user = window.chatController.user
    @started = false
    @stage = 0
    @bindEvents()

  bindEvents: =>
    @dispatcher.bind 'waiting', @waiting
    @dispatcher.bind 'alert', @alertMsg
    @dispatcher.bind 'start_game', @startGame
    @dispatcher.bind 'other_left', @otherLeft
    @dispatcher.bind 'num_pieces_out', @numPiecesOut
    @dispatcher.bind 'put_piece_ad', @putPieceAd
    @dispatcher.bind 'start_new_turn', @startNewTurn
    @dispatcher.bind 'end_game', @endGame
    @dispatcher.bind 'update_game', @updateGame


    $('#ready').on 'click', @getInGame


  put_piece: (place) ->
    @dispatcher.trigger 'game.put_piece', place

  getInGame: (event) ->
    event.preventDefault()
    @user ||= window.chatController.user
    @dispatcher ||= window.chatController.dispatcher
    @dispatcher.trigger 'game.get_in_game', @user

  waiting: (m)->
    @user ||= window.chatController.user
    for user in m.users
      if user == @user.user_id
        @user.cod = 1
        $('[data-piece]').attr('data-p', @user.cod)
        $('#ready').text('Waitind opponent..')
        $('#ready').unbind( "click" )

  otherLeft: (m)->
    @user ||= window.chatController.user
    for user in m.users
      if user == @user.user_id
        $('#ready').text('Your opponent left the game. :(')
        $('#ready').on 'click', @getInGame

  alertMsg: (m)->
    @user ||= window.chatController.user
    for user in m.users
      if user == @user.user_id
        $('[data-piece]').attr('data-p', @user.cod)
        $('#ready').text(m.msg_body)

  startGame: (m)->
    window.gameController.started= true
    window.gameController.stage= 0
    @user ||= window.chatController.user
    for user in m.users
      if user == @user.user_id
        if !@user.cod
          @user.cod = 2
        $('[data-piece]').attr('data-p', @user.cod)
        $('#ready').text(m.msg_body)

  numPiecesOut: (m)->
    @user ||= window.chatController.user
    for user in m.users
      if user == @user.user_id
        index = 0
        for i in m.msg_body
          if i <= 0
            p = $($('.pecas [data-piece="'+(index)+'"]')[0])
            p.attr('draggable', false)
            p.removerAttr('data-p')
            p.removeClass('column')
          index+=1

  putPieceAd: (m)->
    @user ||= window.chatController.user
    for user in m.users
      if user == @user.user_id
        if @user.cod == 1
          a = 2
        else
          a = 1
        $('#'+m.msg_body).attr('data-adv', true);
        $('#'+m.msg_body).attr('data-p', a);

  startNewTurn: (m)->
    @user ||= window.chatController.user
    for user in m.users
      if user == @user.user_id
        window.gameController.stage = 1
        $('#table-pecas').remove()
        if m.msg_body.ultimo == @user.user_id
          $('#status').append('<div id="status-text" class="well text-center">Wait for your opponent..</div>')
        else
          $('#status').append('<div id="status-text" class="well text-center">Make your move</div>')

  move_piece: (arg)->
    @dispatcher ||= window.chatController.dispatcher
    @dispatcher.trigger 'game.move_piece', arg

  endGame: (m)->
    @user ||= window.chatController.user
    for user in m.users
      if user == @user.user_id
        if user == m.msg_body
          alert 'Congratulations! You won the game!'
        else
          alert 'You lost the game. :(('
          
  updateGame: (m)->
    @user ||= window.chatController.user
    for user in m.users
      if user == @user.user_id
        o = m.msg_body
        if o.ultimo == @user.user_id
          $('#status-text').text('Wait for your opponent..')
        else
          $('#status-text').text('Make your move')
        if o.cod == 2
          if user == o.jog
            meu = $('#'+o.peca_pos[0]+'x'+o.peca_pos[1])
            para = $('#'+o.peca_pos_fim[0]+'x'+o.peca_pos_fim[1])
            para.attr('data-piece', meu.attr('data-piece'))
            para.attr('data-p', @user.cod)
            meu.removerAttr('data-piece')
            meu.removerAttr('data-p')
          else
            if @user.cod == 1
              codigo = 2
            else
              codigo = 1
            adv = $('#'+(9-o.peca_pos[0])+'x'+(9-o.peca_pos[1]))
            para = $('#'+(9-o.peca_pos_fim[0])+'x'+(9-o.peca_pos_fim[1]))
            para.attr('data-adv', true)
            para.attr('data-p', codigo)
            adv.removerAttr('data-adv')
            adv.removerAttr('data-p')
        else if o.cod == 0
          if user == o.jog
            adv_t = $('#'+o.peca_adv_pos[0]+'x'+o.peca_adv_pos[1])
            adv_t.attr('data-piece', o.peca_adv)
            setTimeout(->
              adv_t.effect('explode', {complete: -> 
                this.removeAttribute("style")})
              adv_t.removerAttr('data-adv')
              adv_t.removerAttr('data-p')
              adv_t.removerAttr('data-piece')
              meu = $('#'+o.peca_pos[0]+'x'+o.peca_pos[1])
              meu.effect('explode',{complete: -> 
                this.removeAttribute("style")})
              meu.removerAttr('data-p') 
              meu.removerAttr('data-piece') 
            ,
            1000
            )
          else
            adv_t = $('#'+(9-o.peca_pos[0])+'x'+(9-o.peca_pos[1]))
            adv_t.attr('data-piece', o.peca)
            setTimeout( ->
              adv_t.effect('explode',{complete: -> 
                this.removeAttribute("style")})
              adv_t.removerAttr('data-piece')
              adv_t.removerAttr('data-adv')
              adv_t.removerAttr('data-p')
              meu = $('#'+(9-o.peca_adv_pos[0])+'x'+(9-o.peca_adv_pos[1]))
              meu.effect('explode',{complete: -> 
                this.removeAttribute("style")})
              meu.removerAttr('data-piece')
              meu.removerAttr('data-p')
            ,
            1000
            )
        else if o.cod == 1
          if user == o.jog
            adv_t = $('#'+o.peca_adv_pos[0]+'x'+o.peca_adv_pos[1])
            adv_t.attr('data-piece', o.peca_adv)
            setTimeout(->
              adv_t.effect('explode',{complete: -> 
                this.removeAttribute("style")})
              adv_t.removerAttr('data-piece')
              adv_t.removerAttr('data-adv')
              adv_t.removerAttr('data-p')
            ,
            1000
            )
          else
            adv_t = $('#'+(9-o.peca_pos[0]+'x'+(9-o.peca_pos[1])))
            meu = $('#'+(9-o.peca_adv_pos[0]+'x'+(9-o.peca_adv_pos[1])))
            adv_t.attr('data-piece', o.peca)
            setTimeout( ->
              adv_t.removerAttr('data-piece')
              meu.effect('explode',{complete: -> 
                this.removeAttribute("style")})
              meu.removerAttr('data-p')
              meu.removerAttr('data-piece')
            ,
            1000
            )
        else if o.cod == -1
          if user == o.jog
            adv_t = $('#'+o.peca_adv_pos[0]+'x'+o.peca_adv_pos[1])
            meu = $('#'+o.peca_pos[0]+'x'+o.peca_pos[1])
            adv_t.attr('data-piece', o.peca_adv)
            setTimeout(->
              adv_t.removerAttr('data-piece')
              meu.effect('explode',{complete: -> 
                this.removeAttribute("style")})
              meu.removerAttr('data-p')
              meu.removerAttr('data-piece')
            ,
            1000
            )
          else
            adv_t = $('#'+(9-o.peca_pos[0])+'x'+(9-o.peca_pos[1]))
            meu = $('#'+(9-o.peca_pos[0])+'x'+(9-o.peca_pos[1]))
            adv_t.attr('data-piece', o.peca)
            setTimeout(->
              adv_t.effect('explode',{complete: -> 
                this.removeAttribute("style")})
              adv_t.removerAttr('data-piece')
              adv_t.removerAttr('data-p')
              adv_t.removerAttr('data-adv')
            ,
            1000
            )

        

        
