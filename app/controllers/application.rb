# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'rubytorrent'
class ApplicationController < ActionController::Base
  ActiveScaffold.set_defaults do |config|
    listen = ActiveScaffold::DataStructures::ActionLink.new("Listen!")
    listen.type = :table
    listen.action = "listen" # "download"
    listen.inline = false
    listen.parameters = {:controller => "library"}
    config.action_links << listen
  end
  session :session_key => '_mechanical-demons_session_id'
end
