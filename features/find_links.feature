Feature: Get a list of links from tweets for a given hash tag.

In order to see what links are popular for a hash tag
As a power user at the command line
I can see a list of urls using a script

Scenario: Happy flow on production.
Given I am at the command line
When I type "ruby find_links.rb kardashian" at the command line
Then I should see a unique list of urls
