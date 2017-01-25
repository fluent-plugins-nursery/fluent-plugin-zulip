# fluent-plugin-zulip

[Fluentd](http://fluentd.org/) output plugin to post messages to Zulip chat application.

[Zulip](https://zulip.org/) is a powerful open source group chat.

## Configuration

## Plugin helpers

* retry_state
* thread

## Fluent::Plugin::ZulipOutput

* **@log_level** (string) (optional): Allows the user to set different levels of logging for each plugin.
  * Alias: log_level
* **time_as_integer** (bool) (optional): 
* **slow_flush_log_threshold** (float) (optional): The threshold to show slow flush logs
  * Default value: `20.0`.
* **api_endpoint** (string) (required): API endpoint
* **bot_email_address** (string) (required): Bot email address
* **bot_api_key** (string) (required): Bot API key
* **message_type** (enum) (optional): Send message type
  * Available values: private, stream
  * Default value: `stream`.
* **stream_name** (string) (optional): Target stream name
* **recipients** (array) (optional): User names (email address) of the recipients for private message
* **subject** (string) (optional): Topic subject
* **subject_key** (string) (optional): Topic subject from record
* **content_key** (string) (optional): Content from record

### \<secondary\> section (optional) (single)

* **@type** (string) (optional): 
  * Alias: type
* **buffer** () (optional): 
* **secondary** () (optional): 

## Copyright

* Copyright(c) 2017- Kenji Okimoto
* License
  * Apache License, Version 2.0
