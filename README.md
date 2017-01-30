# fluent-plugin-zulip

[Fluentd](http://fluentd.org/) output plugin to post messages to Zulip chat application.

[Zulip](https://zulip.org/) is a powerful open source group chat.

## Installation

### RubyGems

```
$ gem install fluent-plugin-zulip
```

### Bundler

Add following line to your Gemfile:

```
gem "fluent-plugin-zulip"
```

And then execute:

```
$ bundle
```

## Configuration

* See also: Fluent::Plugin::Output

```aconf
<source>
  @type dummy
  dummy { "message": "This is a message" }
  tag dummy.log
</source>

<match **>
  @type zulip
  api_endpoint https://zulip.example.com/api/v1/messages
  bot_email_address test-bot@example.com
  bot_api_key xxxxxxxxxxxxxxxxxxxxxxxxxx
</match>
```

## Fluent::Plugin::ZulipOutput

* **api_endpoint** (string) (required): API endpoint
* **bot_email_address** (string) (required): Bot email address
* **bot_api_key** (string) (required): Bot API key
* **message_type** (enum) (optional): Send message type
  * Available values: private, stream
  * Default value: `stream`.
* **stream_name** (string) (optional): Target stream name
  * Default value: `social`.
* **recipients** (array) (optional): User names (email address) of the recipients for private message
  * Default value: `[]`.
* **subject** (string) (optional): Topic subject
* **subject_key** (string) (optional): Topic subject from record
* **content_key** (string) (optional): Content from record
  * Default value: `message`.

## Copyright

* Copyright(c) 2017- Kenji Okimoto
* License
  * Apache License, Version 2.0
