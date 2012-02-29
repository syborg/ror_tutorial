require 'integration_test_helper'

class MicropostTest < ActionDispatch::IntegrationTest
  fixtures :all

  setup do
    integration_signin
  end

  context "creation" do

    context "failure" do

      should "not make a new micropost" do
        assert_difference 'Micropost.count', 0 do
          visit root_path
          fill_in 'micropost_content', :with => ""
          click_button "Submit"
          assert page.has_selector?("div#error_explanation") # comprovem que conte missatges d'error
        end
      end

    end

    context "success" do

      should "make a new micropost" do
        assert_difference 'Micropost.count', 1 do
          visit root_path
          content = "Lorem ipsum dolor sit amet"
          fill_in 'micropost_content', :with => content
          click_button "Submit"
          assert page.has_selector?("span.content", :text => content)
        end
      end

    end

  end

end
