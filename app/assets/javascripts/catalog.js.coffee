# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#= require cart

loadDescription = (url) ->
  $.ajax
    type: 'POST'
    url: url

$(document).ready ->

  $('#about_sparc').dialog
    autoOpen: false
    modal: true

  $(document).on 'click', '.about_sparc_request', ->
    $('#about_sparc').dialog('open')

  $('#institution_accordion').accordion
    heightStyle: 'content'
    collapsible: true
    activate: (event, ui)->
      if url = (ui.newHeader.find('a').attr('href') or ui.oldHeader.find('a').attr('href'))
        loadDescription(url)

  $('.provider_accordion').accordion
    heightStyle: 'content'
    collapsible: true
    active: false
    activate: (event, ui)->
      if url = (ui.newHeader.find('a').attr('href') or ui.oldHeader.find('a').attr('href'))
        loadDescription(url)
  

  $('.title .name a').live 'click', ->
    $(this).parents('.title').siblings('.service-description').toggle()


  autoComplete = $('#service_query').autocomplete
    source: '/search/services'
    minLength: 2
    search: (event, ui) ->
      $('.catalog-search-clear-icon').remove()
      $("#service_query").after('<img src="/assets/spinner.gif" class="catalog-search-spinner" />')
    open: (event, ui) ->
      $('.catalog-search-spinner').remove()
      $("#service_query").after('<img src="/assets/clear_icon.png" class="catalog-search-clear-icon" />')
      $('.service-name').qtip
        content: { text: false}
        position:
          corner:
            target: "rightMiddle"
            tooltip: "leftMiddle"

          adjust: screen: true

        show:
          delay: 0
          when: "mouseover"
          solo: true

        hide:
          delay: 0
          when: "mouseout"
          solo: true
        
        style:
          tip: true
          border:
            width: 0
            radius: 4

          name: "light"
          width: 250

    close: (event, ui) ->
      $('.catalog-search-spinner').remove()
      $('.catalog-search-clear-icon').remove()

  .data("uiAutocomplete")._renderItem = (ul, item) ->
    if item.label == 'No Results'
      $("<li class='search_result'></li>")
      .data("ui-autocomplete-item", item)
      .append("#{item.label}")
      .appendTo(ul)
    else
      $("<li class='search_result'></li>")
      .data("ui-autocomplete-item", item)
      .append("#{item.parents}<br><span class='service-name' title='#{item.description}'>#{item.label}</span><br><button id='service-#{item.value}' sr_id='#{item.sr_id}' style='font-size: 11px;' class='add_service'>Add to Cart</button><span class='service-description'>#{item.description}</span>")
      .appendTo(ul)
  
  $('.catalog-search-clear-icon').live 'click', ->
    $("#service_query").autocomplete("close")
    $("#service_query").clearFields()

  $('.submit-request-button').click ->
    signed_in = $(this).data('signed-in')

    if $('#line_item_count').val() <= 0
      $('#submit_error').dialog
        modal: true
        buttons:
            Ok: ->
              $(this).dialog('close')
      return false
    #else
    #  if signed_in == false
    #    $('#sign_in').dialog
    #      modal: true
    #    return false
  
  $('#devise_view').dialog
    modal: true
    width: 700
    dialogClass: 'devise_view'

  $('.toggle_outside_user_sign_in').click ->
    $('#outside_sign_in_form').show()
    $('#shibboleth_sign_in_button').hide()
    $(this).hide()
    $('.sign_in_options').hide()

  $('#cancel_registration').click ->
    $('#signup_form').dialog('close')
