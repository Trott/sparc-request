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

# /////////////////////////////////////////////
# //
# // Project - Edit.js for Editing Projects
# //
# /////////////////////////////////////////////

if <%= @protocol.valid? and @current_step == 'return_to_service_request' %>
  window.location.href = "<%= protocol_service_request_path @service_request %>"
else
  #This is to re-enable the submit, it is disabled to prevent multiple posts, if you click rapidly.
  $('a.continue_button').click ->
    $('form').submit()

  $('#current_step').val("<%= @current_step %>")
  if <%= @protocol.valid? and @current_step == "user_details" %>
    $('.return-to-previous a').attr('href', "<%= edit_service_request_project_path(@service_request, @protocol) %>")
    $('.return-to-previous a span').text("Go Back")
    $('.save-and-continue span').text("Save & Continue")
    $('#errorExplanation').hide()
    $('.protocol_details_container').hide()
    $('.user-details-container').show()
  else
    $('.edit_project').html("<%= escape_javascript(render :partial => 'projects/form', :locals => {:project => @project, :service_request => @service_request}) %>")

  # $('.edit_project').html("<%= escape_javascript(render :partial => 'projects/form', :locals => {:project => @project, :service_request => @service_request}) %>")
  # $('.return-to-previous a').attr('href', "<%= edit_service_request_project_path(@service_request, @protocol) %>")
  # $('.return-to-previous a span').text("Go Back")
  # $('.save-and-continue span').text("Save & Continue")
