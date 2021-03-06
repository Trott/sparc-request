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

require 'spec_helper'

feature 'automatic pricing adjustment' do
  background do
    default_catalog_manager_setup
  end
  
  scenario 'successfully creates pricing map with adjusted rates and dates', :js => true do

    wait_for_javascript_to_finish
    click_link('South Carolina Clinical and Translational Institute (SCTR)')

    sleep 3

    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    wait_for_javascript_to_finish
    click_button('Increase or Decrease Rates')
    wait_for_javascript_to_finish
    
    numerical_day = 10

    within('.increase_decrease_dialog') do
      page.execute_script %Q{ $(".percent_of_change").val("20") }
      wait_for_javascript_to_finish

      page.execute_script %Q{ $('.change_rate_display_date').trigger("focus") } #activate data picker
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month      
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on the 10th of next month

      page.execute_script %Q{ $('.change_rate_effective_date').trigger("focus") } #activate data picker
      page.execute_script %Q{ $('a.ui-datepicker-next').trigger("click") } # go forward one month      
      page.execute_script %Q{ $("a.ui-state-default:contains('#{numerical_day}'):first").trigger("click") } # click on the 10th of next month
    end
    
    within('.ui-dialog-buttonset') do
      click_button('Submit')
      wait_for_javascript_to_finish
    end

    page.should have_content('Successfully updated the pricing maps for all of the services under 
                              South Carolina Clinical and Translational Institute (SCTR).')
    
    ## Check to see if a pricing_map was actually created under the service with the correct dates.
    click_link('South Carolina Clinical and Translational Institute (SCTR)')
    wait_for_javascript_to_finish
    click_link('MUSC Research Data Request (CDW)')
    wait_for_javascript_to_finish
    within '#pricing' do
      find('.legend').click
      wait_for_javascript_to_finish
    end
    
    wait_for_javascript_to_finish
    
    within('.pricing_map_accordion') do
      increase_decrease_date = (Date.today + 1.month).strftime("%-m/#{numerical_day}/%Y")
      wait_for_javascript_to_finish
      page.should have_content("Effective on #{increase_decrease_date} - Display on #{increase_decrease_date}")
    end

  end

end
