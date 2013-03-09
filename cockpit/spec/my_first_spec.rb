app = File.expand_path(File.join(File.dirname(__FILE__), '..', 'elexis-cockpit.rb'))
puts app
require app  # <-- your sinatra app
require 'rspec'
require 'rack/test'

set :environment, :test

describe 'The HelloWorld App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "says hello" do
    get '/'
    last_response.should be_ok
    last_response.body.should match /Elexis-Cockpit/
    last_response.body.should match /Auslastung/
    last_response.body.should match /Niklaus Giger/
  end
end