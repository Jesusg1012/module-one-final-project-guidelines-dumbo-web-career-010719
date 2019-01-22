require_relative '../config/environment'
require 'tty-prompt'


def welcome
  prompt = TTY::Prompt.new
  response = prompt.select("Welcome to the Flatiron Dating Sim!", %w(new_game load_game delete_file))
  if response == 'new_game'
    new_game
  elsif response == 'load_game'
    load_game
  elsif response == 'delete_file'
    delete_file
  end
end



welcome
