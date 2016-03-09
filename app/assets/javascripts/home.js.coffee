# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ($) ->
  $.fn.removerAttr = (e) ->
    while $(this).attr(e)
      $(this).removeAttr(e)

jQuery ($) ->
  $.fn.gameTabDragStart = (event) ->
      if window.gameController.stage == 0
        event.stopPropagation()
        event.preventDefault()
        return false
      else if window.gameController.stage == 1 and $(this).attr('data-piece')
        if parseInt($(this).attr('data-piece')) < 2
          event.stopPropagation()
          event.preventDefault()
          return false
        pos = this.id.split 'x'
        pos[0] = parseInt(pos[0])
        pos[1] = parseInt(pos[1])
        if parseInt($(this).attr('data-piece')) == 3
          ind = pos[0] - 1
          c = 0
          while ind >= 0 and !$('#'+ind+'x'+pos[1]).attr('data-piece') and !$('#'+ind+'x'+pos[1]).attr('data-adv') and !$('#'+ind+'x'+pos[1]).attr('data-lago')
            $('#'+ind+'x'+pos[1]).addClass('jogada-possivel')
            ind -= 1
            c +=1
          if $('#'+ind+'x'+pos[1]).attr('data-adv') == 'true'
            $('#'+ind+'x'+pos[1]).addClass('jogada-possivel') 

          ind = pos[0] + 1
          c = 0
          while ind <= 9 and !$('#'+ind+'x'+pos[1]).attr('data-piece') and !$('#'+ind+'x'+pos[1]).attr('data-adv') and !$('#'+ind+'x'+pos[1]).attr('data-lago')
            $('#'+ind+'x'+pos[1]).addClass('jogada-possivel')
            ind += 1
            c += 1
          if $('#'+ind+'x'+pos[1]).attr('data-adv') == 'true'
            $('#'+ind+'x'+pos[1]).addClass('jogada-possivel')

          ind = pos[1] - 1
          c = 0
          while ind >= 0 and !$('#'+pos[0]+'x'+ind).attr('data-piece') and !$('#'+pos[0]+'x'+ind).attr('data-adv') and !$('#'+pos[0]+'x'+ind).attr('data-lago')
            $('#'+pos[0]+'x'+ind).addClass('jogada-possivel')
            ind -= 1
            c += 1
          if $('#'+pos[0]+'x'+ind).attr('data-adv') == 'true'
            $('#'+pos[0]+'x'+ind).addClass('jogada-possivel')

          ind = pos[1] + 1
          c = 0
          while ind <= 9 and !$('#'+pos[0]+'x'+ind).attr('data-piece') and !$('#'+pos[0]+'x'+ind).attr('data-adv') and !$('#'+pos[0]+'x'+ind).attr('data-lago')
            $('#'+pos[0]+'x'+ind).addClass('jogada-possivel')
            ind += 1
            c +=1
          if $('#'+pos[0]+'x'+ind).attr('data-adv') == 'true'
            $('#'+pos[0]+'x'+ind).addClass('jogada-possivel')
        else
          if (pos[0]-1) >= 0 and !$('#'+(pos[0]-1)+'x'+pos[1]).attr('data-piece') and !$('#'+(pos[0]-1)+'x'+pos[1]).attr('data-lago')# and !$('#'+(pos[0]-1)+'x'+pos[1]).data('adv')
            $('#'+(pos[0]-1)+'x'+pos[1]).addClass('jogada-possivel')

          if (pos[0]+1) <= 9 and !$('#'+(pos[0]+1)+'x'+pos[1]).attr('data-piece') and !$('#'+(pos[0]+1)+'x'+pos[1]).attr('data-lago')# and !$('#'+(pos[0]+1)+'x'+pos[1]).data('adv')
            $('#'+(pos[0]+1)+'x'+pos[1]).addClass('jogada-possivel')

          if (pos[1]-1) >= 0 and !$('#'+pos[0]+'x'+(pos[1]-1)).attr('data-piece') and !$('#'+pos[0]+'x'+(pos[1]-1)).attr('data-lago')# and !$('#'+pos[0]+'x'+(pos[1]-1)).data('adv')
            $('#'+pos[0]+'x'+(pos[1]-1)).addClass('jogada-possivel')

          if (pos[1]+1) <= 9 and !$('#'+pos[0]+'x'+(pos[1]+1)).attr('data-piece') and !$('#'+pos[0]+'x'+(pos[1]+1)).attr('data-lago')# and !$('#'+pos[0]+'x'+(pos[1]+1)).data('adv')
            $('#'+pos[0]+'x'+(pos[1]+1)).addClass('jogada-possivel')
        event.dataTransfer.setData('pos_ini', $(this).attr('id'))

jQuery ($) ->
  $.fn.gameTabOnDrop = (event) ->
    event.preventDefault()
    unless window.gameController.started
      alert 'O jogo ainda não começou'
      return false

    if window.gameController.stage == 0
      linha = this.id.split 'x'
      if linha[0] < 6
        alert 'Coloque suas pecas nas ultimas 4 linhas'
        return false
      if $(this).attr('data-piece')
        return false
      src = $(event.dataTransfer.getData('text'))
      src.removeClass('column').addClass('cell')
      src.attr('id', this.id)
      peca_id = src.attr('data-piece')
      obj = src[0]
      obj.ondragstart= $.fn.gameTabDragStart
      obj.ondrop= $.fn.gameTabOnDrop
      obj.ondragenter= $.fn.gameTabOnDragEnter
      obj.ondragover= $.fn.gameTabOnDragOver
      obj.ondragleave= $.fn.gameTabOnDragLeave
      obj.ondragend= $.fn.gameTabOnDragEnd
      data = {pos:this.id, peca:peca_id}
      src.replaceAll($(this))
      window.gameController.put_piece data
    else if window.gameController.stage == 1
      if event.dataTransfer.getData('pos_ini')
        if $(this).hasClass('jogada-possivel')
          msg = 
            pos_ini: event.dataTransfer.getData('pos_ini')
            pos_fim: $(this).attr('id')
          window.gameController.move_piece msg
          return true

jQuery ($) ->
  $.fn.gameTabOnDragEnter= (event) ->

jQuery ($) ->
  $.fn.gameTabOnDragOver= (event) ->
    event.preventDefault()

jQuery ($) ->
  $.fn.gameTabOnDragLeave= (event) ->
    event.preventDefault()

jQuery ($) ->
  $.fn.gameTabOnDragEnd= (event) ->
    event.preventDefault()
    $('.cell').removeClass('jogada-possivel')
    

jQuery ->
  $('.cell').each ->
    this.ondragstart= $.fn.gameTabDragStart
    this.ondrop= $.fn.gameTabOnDrop
    this.ondragenter= $.fn.gameTabOnDragEnter
    this.ondragover= $.fn.gameTabOnDragOver
    this.ondragleave= $.fn.gameTabOnDragLeave
    this.ondragend= $.fn.gameTabOnDragEnd
    
    
  $('#table-pecas .column').each ->
    this.ondragstart=(event) ->
      if window.gameController.stage == 0
        unless $(this).prop('draggable')
          event.stopPropagation()
          event.preventDefault()
          return false
        res = $('<div>').append($(this).clone()).html()
        event.dataTransfer.dropEffect = 'move'
        event.dataTransfer.setData('text', res)
    
    # $(this).on('dragstart', (event) ->
    #   console.log event
    #   console.log 'PECA dragover'
    # )
    this.ondrop= (event) ->
      event.preventDefault()
      # console.log 'PECA event.dataTransfer'

    this.ondragenter= (event) ->
      # console.log 'PECA dragenter'
    
    this.ondragover= (event) ->
      event.preventDefault()
      # console.log 'PECA dragover'

    this.ondragleave= (event) ->
      # console.log 'PECA dragleave'
    
    this.ondragend= (event) ->
      # console.log 'PECA dragend'

$ ->
    $('#4x2').attr('data-lago', true)
    $('#4x3').attr('data-lago', true)
    $('#5x2').attr('data-lago', true)
    $('#5x3').attr('data-lago', true)

    $('#4x6').attr('data-lago', true)
    $('#4x7').attr('data-lago', true)
    $('#5x6').attr('data-lago', true)
    $('#5x7').attr('data-lago', true)
