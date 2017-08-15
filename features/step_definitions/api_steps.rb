require 'jsonpath'
# https://github.com/jayzes/cucumber-api-steps

World(Rack::Test::Methods)

auth_token = ""

Given /^I send and accept XML$/ do
  page.driver.header 'Accept', 'text/xml'
  page.driver.header 'Content-Type', 'text/xml'
end

Given /^I send and accept JSON$/ do
  page.driver.header 'Accept', 'application/json'
  page.driver.header 'Content-Type', 'application/json'
end

When /^I authenticate as the user "([^"]*)" with the password "([^"]*)"$/ do |user, pass|
  # page.driver.authorize(user, pass)
  path = '/api/v1/tokens.json'
  params = {:email=>user, :password=>pass}
  page.driver.post path, params
  if page.respond_to? :should
     page.driver.response.status.should == 200
   else
     assert_equal 200, page.driver.response.status
   end
   
  json = JSON.parse(page.driver.response.body)
  auth_token = json['token']  
end

When /^I send a GET request (?:for|to) "([^"]*)"$/ do |path|
  path = "#{path}?auth_token=#{auth_token}"
  page.driver.get path
end

When /^I send a POST request to "([^"]*)"$/ do |path|
  page.driver.post path
end

When /^I send a POST request to "([^"]*)" with the following params:$/ do |path, params_string|
  params = eval(params_string)
  page.driver.post path, params
end

When /^I send a PUT request to "([^"]*)" with the following params:$/ do |path, params_string|
  params = eval(params_string)
  page.driver.put path, params
end

When /^I send a DELETE request to "([^"]*)"$/ do |path|
  page.driver.delete path
end

Then /^show me the response$/ do
  p page.driver.response
end

Then /^the response status should be "([^"]*)"$/ do |status|
  if page.respond_to? :should
    page.driver.response.status.should == status.to_i
  else
    assert_equal status.to_i, page.driver.last_response.status
  end
end

Then /^the JSON response should have "([^"]*)" with the text "([^"]*)"$/ do |json_path, text|
  json = JSON.parse(page.driver.last_response.body)
  results = JsonPath.new(json_path).on(json).to_a.map(&:to_s)
  if page.respond_to? :should
    results.should include(text)
  else
    assert results.include?(text)
  end
end

Then /^the JSON response should not have "([^"]*)" with the text "([^"]*)"$/ do |json_path, text|
  json = JSON.parse(page.driver.last_response.body)
  results = JsonPath.new(json_path).on(json).to_a.map(&:to_s)
  if page.respond_to? :should
    results.should_not include(text)
  else
    assert !results.include?(text)
  end
end

Then /^the XML response should have "([^"]*)" with the text "([^"]*)"$/ do |xpath, text|
  parsed_response = Nokogiri::XML(last_response.body)
  elements = parsed_response.xpath(xpath)
  if page.respond_to? :should
    elements.should_not be_empty, "could not find #{xpath} in:\n#{last_response.body}"
    elements.find { |e| e.text == text }.should_not be_nil, "found elements but could not find #{text} in:\n#{elements.inspect}"
  else
    assert !elements.empty?, "could not find #{xpath} in:\n#{last_response.body}"
    assert elements.find { |e| e.text == text }, "found elements but could not find #{text} in:\n#{elements.inspect}"
  end
end

