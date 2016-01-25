require 'rainforest'

# Get your api key from https://app.rainforestqa.com/settings/integrations
Rainforest.api_key = "your-api-key"

# We'll delete all tests tagged "scripted", then upload new ones
# and tag them again, ensuring a clean house each time. Run history
# will preserve the historic ones regardless of deletion.
tag_to_delete = "scripted"


# Edit these step options
#
# title: part of the tests title, which will be combined
# action: what the tester should do
# response: the question to ask the tester about what they did
#

step_1_options = [
  {title: "1", action: "login using {{random.email}} and {{random.password}}", response: "are you logged in?"},
  {title: "2", action: "login using {{random.email}} and xxxx", response: "are you logged in?"},
  {title: "3", action: "login using {{logins.email}} and {{logins.password}}", response: "are you logged in?"},
]

step_2_options = [
  {title: "a", action: "click on the dashboard", response: "Do you see a dashboard?"},
  {title: "b", action: "some action", response: "did it work?"},
  {title: "c", action: "click on the link {{ad.link}}", response: "does it look like {{ad.image}}?"},
]

# delete all tests tagged tag_to_delete
Rainforest::Test.all.each do |test|
  Rainforest::Test.delete(test.id) if test.tags.include?(tag_to_delete)
end


# Work out the combinations of the above...
all_steps = [step_1_options, step_2_options]
all_steps.first.product(*all_steps[1..-1]).each do |test|
  # Work out the title of the combination
  title = "Scripted: " + test.map {|step| step[:title] }.join(" + ")

  # Turn the steps to elements (note, they're all "step" as we don't use embeded tests here)
  elements = test.map do |step|
    {type: "step", redirection: true, element: {action: step[:action], response: step[:response]}}
  end

  # Create the test
  Rainforest::Test.create({
    start_uri: "/",
    title: title,
    tags: [tag_to_delete],
    elements: elements
    })
end