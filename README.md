# lita-mailgun

A lita plugin for interacting with mailgun.com.

## Installation

Add this gem to your lita installation by including the following line in your Gemfile:

    gem "lita-mailgun"

## Externally triggered events

This handler can accept mailgun events and trigger a variety of activities as appropriate. To
get started, use the mailgun web interface to configure a webhook that POSTs events to:

    http://your-lita-bot.com/mailgun

### Dropped Email Reports

To print a warning when a high number of recent emails to a domain were
dropped, edit your lita\_config.rb to include the following line.

    config.handlers.mailgun_droppped_rate.channel_name = "channel-name"

The warnings will look something like this:

    [mailgun] [bigpond.net.au] 8/10 (80.0%) recent emails dropped

## Chat commands

This handler provides no additional chat commands. Yet.

## TODO

Possible ideas for new features, either via chat commands or externally triggered events:

* maybe set a maximum period of time to store the event data?
* maybe record the number of unique addresses that have failed, and skip warning
  if all failures are to 1 or 2 addresses. We're looking for issues that are likely
  domain wide, not a single mailbox
