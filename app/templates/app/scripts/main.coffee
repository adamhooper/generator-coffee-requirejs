# We need config.js to be a JavaScript file because Grunt will edit it.
# How do we read config.js? Using require.js!
#
# If you're not absolutely sure you understand what's happening here, the
# summary is: do not modify the next line.
require [ './config' ], ->
  # Now that we've read config.js, use require() the way you normally would.
  require [
    # Dependencies go here
  ], (
    # Their assigned names go here
  ) ->
    # What you do with them goes here
