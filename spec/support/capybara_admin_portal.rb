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

module CapybaraAdminPortal

    def goToSparcProper(un='jug2',pwd='p4ssword')
        #navigates to sparc proper catalog and logs in if not already logged in.
        visit root_path
        wait_for_javascript_to_finish
        if have_xpath("//div[@class='welcome']/span[text()='Not Logged In']") then
            login("#{un}","#{pwd}")
        end
        wait_for_javascript_to_finish
    end

    def goToAdminPortal
        #navigates to admin portal
        visit "/portal/admin"
        wait_for_javascript_to_finish
    end

    def login(un,pwd)
        #logs the user in the custom username and password.
        currentUrl = page.current_url
        visit "/identities/sign_in"
        wait_for_javascript_to_finish
        loginDiv = first(:xpath,"//div[@id='login']")
        if loginDiv.nil? then 
            if not currentUrl==page.current_url then visit "#{currentUrl}" end
            wait_for_javascript_to_finish
            return #if the login dialog is not displayed quit here.
        end 
        click_link "Outside Users Click Here"
        wait_for_javascript_to_finish
        fill_in "identity_ldap_uid", :with => un
        fill_in "identity_password", :with => pwd
        first(:xpath, "//input[@type='submit' and @value='Sign In']").click
        wait_for_javascript_to_finish
    end

    def waitAndClickOff
        #allows javascript to complete
        #by clicking in a nonactive part of the page
        #then calls wait for javascript to finish method.
        #equivalent of clickOffAndWait in CapybaraProper, 
        #however a different part of the page is clicked as
        #the xpath used in CapybaraProper is unavailable in the Admin Portal.
        first(:xpath, "//div[@id='welcome_msg']/span").click
        wait_for_javascript_to_finish
    end    

    def notificationTest
        #clicks to send notification and checks that notification dialog appears, then closes the dialog.  
        find(:xpath, "//ul[@class='fulfillment_notifications']/li[1]").click
        wait_for_javascript_to_finish
        page.should have_xpath "//div[contains(@class,'ui-dialog') and contains(@style,'display: block;')]"
        find(:xpath, "//div[contains(@class,'ui-dialog') and contains(@style,'display: block;')]//button/span[text()='Cancel']").click
        wait_for_javascript_to_finish
    end

    def documentsTabTest
        #goes to documents tab, adds a new document
        switchTabTo "Documents"
        click_link "Add a New Document"
        wait_for_javascript_to_finish
        first(:xpath,"//input[@id='document']").set("/Users/charlie/Documents/GitHub/sparc-rails/spec/features/quick_happy_test_spec.rb")
        select "Other", :from => "doc_type"
        click_link "Upload"
        wait_for_javascript_to_finish
    end

    def searchBoxTest(upBoolean, searchText)
        #Expects a boolean whether the search is being done in User Portal or not
        #If not, assumes test is in admin portal or CWF
        #also expects a string of text to enter into the search box and expects that
        #that string will appear in one of the responses as well. 
        #types searchText into search box then if a response exists with the searchText in it,
        #clicks on that response.
        wait_for_javascript_to_finish
        if upBoolean then searchBox = find(:xpath, "//input[@id='search_box']")
        else searchBox = find(:xpath, "//input[contains(@class,'search-all-service-requests')]") end 
        searchBox.set(searchText)
        wait_for_javascript_to_finish
        response = first(:xpath, "//ul/li[@role='presentation']/a[contains(text(),'#{searchText}')]")
        if not response.nil? then response.click end
    end        

    def enterServiceRequest(studyShortName, serviceName)
        #clicks on a specific row in the admin portal display table
        searchBoxTest(false, "Julia Glenn")
        find(:xpath, "//table[@id='admin-tablesorter']/tbody/tr/td/ul/span[text()='#{serviceName}']/ancestor::tr/td[text()='#{studyShortName}']").click
        wait_for_javascript_to_finish
    end

    def expectToastMessage
        #checks for presence of toast message
        page.should have_xpath("//div[@class='toast-item-wrapper']")
    end

    def expectStatusChangeRecord(changedFrom, changedTo)
        #checks for presence of record in Status Changes table
        page.should have_xpath("//table[@id='status_history_table']/tbody/tr/td[contains(text(),'#{changedFrom}')]/following-sibling::td[contains(text(),'#{changedTo}')]")
    end

    def addNote(text)
        #adds a new note and checks that the note was added
        fill_in "notes", :with => text
        click_link "Add Note"
        page.should have_xpath("//div[@class='note_body' and text()='#{text}']")
    end

    def associatedUsersTest(usersID, usersName)
        #switches to Associated Users tab, if user is already there deletes the user from the request, 
        #adds the user via the dialog box.
        switchTabTo "Associated Users"

        if have_xpath "//tr[contains(@id,'user_')]/td[contains(text(),'#{usersName}')]" then
            find(:xpath, "//tr[contains(@id,'user_')]/td[contains(text(),'#{usersName}')]/parent::tr/td[@class='delete']/a").click
            page.driver.browser.switch_to.alert.accept
        end

        wait_for_javascript_to_finish
        find(:xpath, "//div[@class='associated-user-button ui-corner-all']").click
        wait_for_javascript_to_finish

        addBox = find(:xpath, "//div[contains(@class,'ui-dialog') and contains(@style,'display: block;')]")
        addBox.find(:xpath, ".//input[@id='user_search']").set(usersID)
        wait_for_javascript_to_finish
        find(:xpath, "//ul[contains(@class,'ui-autocomplete')]/li/a[contains(text(),'#{usersName}')]").click
        wait_for_javascript_to_finish
        select "Other", :from => 'project_role_role'
        find(:xpath, "//input[@id='project_role_project_rights_approve']").click

        addBox.find(:xpath, ".//button/span[text()='Submit']").click
        wait_for_javascript_to_finish

        page.should have_xpath "//tr[contains(@id,'user_')]/td[contains(text(),'#{usersName}')]"
    end

    def testSubsidy(percentage)
        #expects a number between 0 and 100
        #changes the % Subsidy field and checks that 
        #the page reflects the change
        switchTabTo "Fulfillment"

        click_link "Add a Subsidy"
        wait_for_javascript_to_finish
        decimal = (percentage.to_f/100.0)
        currentCost = first(:xpath, "//span[@class='effective_cost']").text[1..-1].to_f
        userDisplayCost = first(:xpath, "//span[@class='display_cost']").text[1..-1].to_f
        piContribution = (currentCost*(1-decimal)).round(2)
        subCurrentCost = (currentCost*decimal).round(2)
        subDisplayCost = (userDisplayCost*decimal).round(2)

        fill_in "subsidy_percent_subsidy", :with => "#{percentage}"
        waitAndClickOff

        find(:xpath, "//input[@id='subsidy_pi_contribution']")['value'].to_f.should eq(piContribution)
        find(:xpath, "//td[@class='subsidy_effective_current_cost']").text[1..-1].to_f.should eq(subCurrentCost)
        find(:xpath, "//td[@class='subsidy_user_display_cost']").text[1..-1].to_f.should eq(subDisplayCost)

        find(:xpath, "//div[@id='subsidy_table']//a[@class='delete_data']/img[@alt='Cancel']").click
        wait_for_javascript_to_finish
    end

    def testOTFService(service,quantity)
        #expects instance of ServiceWithAddress, and integer quantity as input
        #quantity will round down if not integer and will be input to service quantity box.
        #the cost will then 

        if not service.otf then return end #if service sent in was not one time fee, stop here.
        unitPrice = service.unitPrice
        fill_in "line_item_quantity", :with => quantity
        expectToastMessage
        waitAndClickOff
        quantity = quantity.floor
        expectedCost = (unitPrice/2*quantity).round(2) #divided by 2 here because the effective percentage is 50
        #this makes this method only effective for the SR of the happy_test suite until effective percentage is
        #pulled out from either the SR or service. 
        first(:xpath, "//div[@id='one_time_fee_table']/table/tbody/tr/td[contains(@id,'_cost')]").text[1..-1].to_f.should eq(expectedCost)
        wait_for_javascript_to_finish
    end

    def testPPService(service)
        find(:xpath, "//a[@class='add_arm_link']").click
        wait_for_javascript_to_finish
        currentBox = find(:xpath, "//div[contains(@class,'ui-dialog') and contains(@style,'display: block;')]")
        currentBox.find(:xpath, ".//button/span[text()='Submit']").click
        wait_for_javascript_to_finish

        find(:xpath, "//a[@class='remove_arm_link']").click
        page.driver.browser.switch_to.alert.accept
        wait_for_javascript_to_finish

        visitText = find(:xpath, "//select[@id='visit_position']/option[@value='']").text[4..-1]
        visitDay = visitText[6..-1]
        find(:xpath, "//a[@class='add_visit_link']").click
        currentBox = find(:xpath, "//div[contains(@class,'ui-dialog ') and contains(@style,'display: block;')]")
        within currentBox do
            fill_in 'visit_name', :with => visitText
            fill_in 'visit_day', :with => visitDay
            find(:xpath, ".//button/span[text()='Submit']").click
            wait_for_javascript_to_finish
        end

        select "Delete #{visitText} - #{visitText}", :from => 'delete_visit_position'
        find(:xpath, "//a[@class='delete_visit_link']").click
        wait_for_javascript_to_finish
    end

    def onTab(tabName)
        #returns boolean for condition: if on tab of tabName string arg.
        return first(:xpath, "//li[@role='tab' and @aria-selected='true']/a[text()='#{tabName}']").present?
    end

    def statusChangeTest
        #changes the status, expects toast messages, and checks history for status change.
        switchTabTo "Fulfillment"

        select "Get a Quote", :from => "sub_service_request_status"
        expectToastMessage
        wait_for_javascript_to_finish
        select "Submitted", :from => "sub_service_request_status"
        expectToastMessage
        wait_for_javascript_to_finish
        expectStatusChangeRecord("Get a Quote","Submitted")
    end

    def switchTabTo(tab)
        #switches to tab with name passed in by argument 'tab'
        if not onTab("#{tab}") then
            find(:xpath, "//li[@role='tab']/a[contains(@class,'-tab ui-tabs-anchor') and contains(text(),'#{tab}')]").click
            wait_for_javascript_to_finish
        end
    end

    def sendToCWF
        #checks "Ready for Clinical Work Fulfillment" checkbox
        switchTabTo 'Fulfillment'
        find(:xpath, "//input[@id='in_work_fulfillment' and @class='cwf_data']").click
        wait_for_javascript_to_finish
    end

    def checkTabsAP
        #runs through each tab
        wait_for_javascript_to_finish
        switchTabTo 'Project/Study Information'
        wait_for_javascript_to_finish

        switchTabTo 'Documents'
        wait_for_javascript_to_finish
        
        switchTabTo 'Related Service Requests'
        wait_for_javascript_to_finish
        
        switchTabTo 'Associated Users'
        wait_for_javascript_to_finish
        
        switchTabTo 'Notifications'
        wait_for_javascript_to_finish
        
        switchTabTo 'Fulfillment'
        wait_for_javascript_to_finish
    end

    def adminPortal(study, service)
        #expects instance of CustomStudy as input 
        #expects instance of ServiceRequestForComparison as input 
        #Intended as full admin portal happy test.
        goToAdminPortal
        enterServiceRequest(study.short,service.name)

        statusChangeTest
        addNote ("This is a Note")

        testSubsidy(50)
        testSubsidy(40)
        testSubsidy(30)

        switchTabTo "Fulfillment"
        if service.otf then 
            testOTFService(service,20)
            testOTFService(service,3)
            testOTFService(service,service.quantity)
        else 
            testPPService(service)
        end

        notificationTest
        documentsTabTest
        associatedUsersTest("bjk7", "Brian Kelsey")

        switchTabTo "Fulfillment"

        if not service.otf then 
            sendToCWF 
        end

    end

end