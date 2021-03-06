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
#= require navigation

$ ->
  # handle removing an arm and clicking save & continue - set subjects and visits to 1 
  # show/hide remove arm link depending on how many arms exist,  hide when on one arm remains
  nested_field_count = $('form .fields:visible').length
  $remove_link = $('a.remove_nested_fields')

  toggleRemoveLink = ->
    $('a.remove_nested_fields').toggle(nested_field_count > 1)
  
  $(document).on 'nested:fieldRemoved:arms', (event) ->
    field = event.field
    button = field.find('.remove_arm')

    if button.hasClass('cannot_remove')
      button.show()
      field.show()
      hiddenField = button.prev('input[type=hidden]')
      hiddenField.val('0')
      alert("This arm has subject data and cannot be removed")
    else
      field.find('.skinny_fields input').val('1')
      nested_field_count -= 1
      toggleRemoveLink()

  $(document).on 'nested:fieldAdded:arms', ->
    nested_field_count += 1
    toggleRemoveLink()

  toggleRemoveLink()

  # end code to show/hide remove arm link

  $("#start_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#project_start_date, #study_start_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date')
  
  $("#end_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#project_end_date, #study_end_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date')

  $('#start_date').attr("readOnly", true)
  $('#end_date').attr("readOnly", true)


  #Recruitment Date Stuff

  $("#recruitment_start_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#project_recruitment_start_date, #study_recruitment_start_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date');
  
  $("#recruitment_end_date").datepicker(
    changeMonth: true,
    changeYear:true,
    constrainInput: true,
    dateFormat: "m/dd/yy",
    showButtonPanel: true,
    altField: '#project_recruitment_end_date, #study_recruitment_end_date',
    altFormat: 'yy-mm-dd',

    beforeShow: (input)->
      callback = ->
        buttonPane = $(input).datepicker("widget").find(".ui-datepicker-buttonpane")
        buttonPane.find('button.ui-datepicker-current').hide()
        $("<button>", {
          class: "ui-state-default ui-priority-primary ui-corner-all"
          text: "Clear"
          click: ->
            $.datepicker._clearDate(input)
        }).appendTo(buttonPane)
      setTimeout( callback, 1)
    ).addClass('date');

  $('#recruitment_start_date').attr("readOnly", true)
  $('#recruitment_end_date').attr("readOnly", true)

  # Validations for existing arms

  $(document).on('change', '.arm_subject_count', ->
    new_count = $(this).val()
    min_count = $(this).data('minimum_subject_count')
    if new_count < min_count
      alert("You can not reduce the subject count below the count of a previously defined arm.")
      $(this).val(min_count)
  )

  $(document).on('change', '.arm_visit_count', ->
    new_count = $(this).val()
    min_count = $(this).data('minimum_visit_count')
    if new_count < min_count
      alert("You can not reduce the visit count below the count of a previously defined arm.")
      $(this).val(min_count)
  )

  $('#navigation_form').submit ->
    go = true
    $('.line_item_quantity').each ->
      if verify_unit_minimum($(this)) == false
        go = false
    return go

$('.units_per_quantity').live 'change', ->
  max = parseInt($(this).attr('data-qty_max'), 10)
  user_input = parseInt($(this).val(), 10)
  if user_input > max
    $(this).css({'border': '2px solid red'})
    $('#unit_max_error').css({'border': '2px solid red'})
    $('#unit_quantity').html(user_input)
    $('#unit_max').html(max + ".")
    $('#unit_max_error').show()
    $(this).val(max)
  else
    $('#unit_max_error').hide()
    $('#unit_max_error').css('border', '')
    $(this).css('border', '')

verify_unit_minimum = (obj) ->
  unit_min = parseInt(obj.attr('unit_minimum'), 10)
  prev_qty = obj.attr('current_quantity')
  qty = parseInt(obj.val(), 10)
  if qty < unit_min
    obj.val(prev_qty)
    obj.css({'border': '2px solid red'})
    $('#quantity').html(qty)
    $('#unit_minimum').html(unit_min + ".")
    $('#one_time_fee_errors').show()
    return false
  else
    $('#one_time_fee_errors').hide()
    obj.css('border', '')
