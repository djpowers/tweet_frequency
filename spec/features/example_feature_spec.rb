require 'spec_helper'

feature "User views the index page" do
  scenario "user sees the correct title" do
    visit '/'

    expect(page.title).to include "You Tweet Too Much"
    expect(page).to have_content "You Tweet Too Much"
  end
end
