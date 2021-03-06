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
require 'surveyor/parser'
require 'rake'

describe "review page", :js => true do
  let_there_be_lane
  let_there_be_j
  fake_login_for_each_test
  build_service_request_with_project

  before :each do
    file = File.join(Rails.root, 'surveys/system_satisfaction_survey.rb')
    Surveyor::Parser.parse_file(file, {:trace => Rake.application.options.trace})
    add_visits
    visit review_service_request_path service_request.id
  end

  # This test does not currently work with group validations. Verified that what this is
  # testing does change the status from 'submitted' to 'draft'. 
  # describe "clicking save and exit/draft" do
  #   it 'Should save request as a draft' do
  #     find('.save-as-draft').click

  #     service_request_test = ServiceRequest.find(service_request.id)
  #     service_request_test.status.should eq("draft")
  #   end
  # end

  describe "clicking submit" do
    it 'Should submit the page', :js => true do
      find("#submit_services2").click
      wait_for_javascript_to_finish
      click_button("No")
      wait_for_javascript_to_finish
      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.status.should eq("submitted")
    end
  end
    
  describe "clicking get a quote and declining the system satisfaction survey" do
    it 'Should submit the page', :js => true do
      find("#get_a_quote").click
      find(:xpath, "//button/span[text()='No']/..").click
      wait_for_javascript_to_finish
      service_request_test = ServiceRequest.find(service_request.id)
      service_request_test.status.should eq("get_a_quote")
    end
  end
    
  describe "clicking get a quote and accepting the system satisfaction survey" do
    it 'Should submit the page', :js => true do
      find("#get_a_quote").click
      find(:xpath, "//button/span[text()='Yes']/..").click
      wait_for_javascript_to_finish

      # select Yes to next question and you should see text area for Yes
      all("#r_1_answer_id_input input").first().click
      wait_for_javascript_to_finish
      fill_in "r_2_text_value", :with => "I love it"
      
      # select No to next question and you should see text area for No
      all("#r_1_answer_id_input input").last().click
      wait_for_javascript_to_finish
      fill_in "r_3_text_value", :with => "I hate it"

      within(:css, "div.next_section") do
        click_button 'Submit'
        wait_for_javascript_to_finish
      end
    end
  end

  context 'epic emails' do

    before :each do
      stub_const("QUEUE_EPIC", false) 
      stub_const("USE_EPIC", true) 
      service2.update_attributes(send_to_epic: true)
      clear_emails
      find("#submit_services2").click
      wait_for_javascript_to_finish
      click_button("No")
      wait_for_javascript_to_finish
      @email = all_emails.find { |email| email.subject == "Epic Rights Approval"}
      service_request.update_attributes(status: 'submitted')
    end

    it 'should send an email to the Epic admins' do
      @email.should have_content "To approve the users and rights"
    end

    # Table is filled correctly
    it 'should have the correct users in the table' do
      visit_email @email
      project_role = project.project_roles.first

      page.should_not have_content project.project_roles.last.identity.full_name

      within("#project_role_#{project.project_roles.first.id}") do
        find(".name").should have_content project_role.identity.full_name
        find(".role").should have_content USER_ROLES.invert[project_role.role]
        find(".epic_rights").should have_content(EPIC_RIGHTS["view_rights"])
      end
    end

    # Primary PI link
    it 'should be able to click the send to primary pi link' do
      visit_email @email
      click_link "Send to Primary PI"
      page.should have_content "Thank you. An email has been sent to the primary PI for the final approval."
    end

    context 'primary pi emails' do
      before :each do
        visit_email @email
        clear_emails
        click_link "Send to Primary PI"

        @email = all_emails.find { |email| email.subject == "Epic Rights User Approval"}
      end

      it "should send an email to the Primary PI" do
        @email.should have_content("The following SPARC Request users have requested access to Epic for your study ##{project.id}")
      end

      it "should have the correct users in the table" do
        visit_email @email
        project_role = project.project_roles.first

        page.should_not have_content project.project_roles.last.identity.full_name

        within("#project_role_#{project.project_roles.first.id}") do
          find(".name").should have_content project_role.identity.full_name
          find(".role").should have_content USER_ROLES.invert[project_role.role]
          find(".epic_rights").should have_content(EPIC_RIGHTS["view_rights"])
        end
      end

      it "should send the study to epic" do
        visit_email @email
        click_link "Send to Epic"
        page.should have_content "Study has been sent to Epic"
      end

      it "should not send services missing cpt code" do
        visit_email @email
        click_link "Send to Epic"
        page.should have_content "#{service2.name} does not have a CPT code."
      end
    end
  end
end
