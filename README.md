# fluent-plugin-zulip

[Fluentd](http://fluentd.org/) output plugin to post messages to Zulip chat application.

[Zulip](https://zulip.org/) is a powerful open source group chat.

## Requirements

| fluent-plugin-zulip | fluentd    | ruby   |
|---------------------|------------|--------|
| >= 0.1.0            | >= v0.14.0 | >= 2.1 |
| N/A                 | >= v0.12.0 | >= 1.9 |

NOTE: fluent-plugin-zulip doesn't support Fluentd v0.12.x

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

* **site** (string) (required): Site URI
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
