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

$(document).ready ->
  # $(".visit_name").live 'mouseover', ->
  $(".visit_name").qtip
    overwrite: false
    content: "Click to rename your visits."
    position:
      corner:
        target: 'bottomLeft'
    show:
      ready: false

  # $('.visit_day').live 'mouseover', ->
  $('.visit_day').qtip
    overwrite: false
    content: "Click to set the visits day. All days must be in numerical order. Ex. 1, 2, 4, 9"
    position:
      corner:
        target: 'topLeft'
        tooltip: 'bottomLeft'
    show:
      ready: false

  # $('.visit_window').live 'mouseover', ->
  $('.visit_window').qtip
    overwrite: false
    content: "Click to set the window period the visit can be completed."
    position:
      corner:
        target: 'topLeft'
        tooltip: 'bottomLeft'
    show:
      ready: false

  $('.jump_to_visit').qtip
    overwrite: false
    content: "Select the visit you would like to view."
    position:
      corner:
        target: 'topLeft'
        tooltip: 'bottomLeft'
    show:
      ready: false

  $('#service_calendar').tabs
    show: (event, ui) -> 
      $(ui.panel).html('<div class="ui-corner-all" style = "border: 1px solid black; padding: 25px; width: 200px; margin: 30px auto; text-align: center">Loading data....<br /><img src="/assets/spinner.gif" /></div>')
    select: (event, ui) ->
      $(ui.panel).html('<div class="ui-corner-all" style = "border: 1px solid black; padding: 25px; width: 200px; margin: 30px auto; text-align: center">Loading data....<br /><img src="/assets/spinner.gif" /></div>')

  # $('.billing_type_list').live 'mouseover', ->
  $('.billing_type_list').qtip
    overwrite: false
    content: 'R = Research<br />T = Third Party (Patient Insurance)<br />% = % Effort'
    position:
      corner:
        target: 'topMiddle'
        tooltip: 'bottomLeft'
    show:
      ready: false
    style:
      tip: true
      border:
        width: 0
        radius: 4
      name: 'light'
      width: 260

  changing_tabs_calculating_rates = ->
    arm_ids = []
    $('.arm_calendar_container').each (index, arm) ->
      if $(arm).is(':hidden') == false then arm_ids.push $(arm).data('arm_id')

    i = 0
    while i < arm_ids.length
      calculate_max_rates(arm_ids[i])
      i++

  if $('.line_item_visit_template').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_billing').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_quantity').is(':visible')
    changing_tabs_calculating_rates()
  else if $('.line_item_visit_pricing').is(':visible')
    changing_tabs_calculating_rates()

