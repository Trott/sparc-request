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

feature 'create new program', :js => true do
  scenario 'user creates a new program' do
    default_catalog_manager_setup
    
    click_link('Create New Program')

    get_alert_window do |prompt|
      prompt.send_keys("The Program")
      prompt.accept

      click_link('The Program')

      # General Information fields
      fill_in 'program_abbreviation', :with => 'PTP'
      fill_in 'program_order', :with => '2'
      fill_in 'program_description', :with => 'Description'
      # Subsidy Information fields
      within '#pricing' do
        find('.legend').click
        wait_for_javascript_to_finish
      end
      fill_in 'program_subsidy_map_attributes_max_percentage', :with => '55.5'
      fill_in 'program_subsidy_map_attributes_max_dollar_cap', :with => '65'

      page.execute_script("$('#save_button').click();")
      page.should have_content( 'The Program saved successfully' )
    end
  end
  
  scenario ': a user with only access to this provider can see link for: Create New Program' do
    create_default_data  
      
    identity = Identity.create(last_name: 'Miller', first_name: 'Robert', ldap_uid: 'rmiller@musc.edu', email:  'rmiller@musc.edu', password: 'p4ssword',password_confirmation: 'p4ssword',  approved: true )
    identity.save!

    provider = Provider.find_by_name('South Carolina Clinical and Translational Institute (SCTR)')
    
    cm = CatalogManager.create( organization_id: provider.id, identity_id: identity.id, )
    cm.save!

    login_as(Identity.find_by_ldap_uid('rmiller@musc.edu'))
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
    expect(page).to have_content('Create New Program')
  end
end
