# lita-mailgun

A lita plugin for interacting with mailgun.com.

## Installation

Add this gem to your lita installation by including the following line in your Gemfile:

    gem "lita-mailgun"

## Externally triggered events

This handler can accept mailgun events and trigger a variety of activities as appropriate. To
get started, use the mailgun web interface to configure a webhook that POSTs events to:

    http://your-lita-bot.com/mailgun

## Chat commands

This handler provides no additional chat commands. Yet.

## TODO

Possible ideas for new features, either via chat commands or externally triggered events:

* more specs
