require 'test_helper'

class LayoutLinksTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "should have Home page at '/'" do
    get '/'
    assert_select "title", :text=>/.*Home$/
  end

  test "should have Contact page at '/contact'" do
    get '/contact'
    assert_select "title", :text=>/.*Contact$/
  end

  test "should have About page at '/about'" do
    get '/about'
    assert_select "title", :text=>/.*About$/
  end

  test "should have Help page at '/help'" do
    get '/help'
    assert_select "title", :text=>/.*Help$/
  end

end
