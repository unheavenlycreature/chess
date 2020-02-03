# Chess

This directory contains a command line version of Chess for two players, implemented in Ruby
as the [final assignment](https://www.theodinproject.com/courses/ruby-programming/lessons/ruby-final-project?ref=lnav) from the Ruby Programming section of [The Odin Project](https://www.theodinproject.com).

## Requirements
Playing this game requires Ruby. You can check whether you have
it installed by seeing if the following produces a Ruby version number in your terminal.

`$ ruby -v`

If it does not, follow the directions [here](https://www.ruby-lang.org/en/documentation/installation/) to install Ruby.

Additionally, this game leverages the colorize gem ([Github](https://github.com/fazibear/colorize), [RubyGems](https://rubygems.org/gems/colorize/versions/0.8.1)) to color the board and chess pieces. To install the gem, run the following from your terminal.

`$ gem install colorize`

## Running the Game

To play the game, simply run the following from the root of the cloned repository.

`$ ruby lib/chess.rb`

## Saving your Game

At any time during play, you can save your game by entering `s` as your command and hitting enter. The game will create a `saves` directory and write the save file there. To resume, select `N` when asked to start a new game, and you'll be asked to provide the name of your save file.