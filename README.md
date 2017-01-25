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

### \<buffer\> section (optional) (single)

* **@type** (string) (optional): 
  * Default value: `memory`.
  * Alias: type
* **timekey** (time) (optional): 
* **timekey_wait** (time) (optional): 
  * Default value: `600`.
* **timekey_use_utc** (bool) (optional): 
* **timekey_zone** (string) (optional): 
  * Default value: `+0900`.
* **flush_at_shutdown** (bool) (optional): If true, plugin will try to flush buffer just before shutdown.
* **flush_mode** (enum) (optional): How to enqueue chunks to be flushed. "interval" flushes per flush_interval, "immediate" flushes just after event arrival.
  * Available values: default, lazy, interval, immediate
  * Default value: `default`.
* **flush_interval** (time) (optional): The interval between buffer chunk flushes.
  * Default value: `60`.
* **flush_thread_count** (integer) (optional): The number of threads to flush the buffer.
  * Default value: `1`.
* **flush_thread_interval** (float) (optional): Seconds to sleep between checks for buffer flushes in flush threads.
  * Default value: `1.0`.
* **flush_thread_burst_interval** (float) (optional): Seconds to sleep between flushes when many buffer chunks are queued.
  * Default value: `1.0`.
* **delayed_commit_timeout** (time) (optional): Seconds of timeout for buffer chunks to be committed by plugins later.
  * Default value: `60`.
* **overflow_action** (enum) (optional): The action when the size of buffer exceeds the limit.
  * Available values: throw_exception, block, drop_oldest_chunk
  * Default value: `throw_exception`.
* **retry_forever** (bool) (optional): If true, plugin will ignore retry_timeout and retry_max_times options and retry flushing forever.
* **retry_timeout** (time) (optional): The maximum seconds to retry to flush while failing, until plugin discards buffer chunks.
  * Default value: `259200`.
* **retry_max_times** (integer) (optional): The maximum number of times to retry to flush while failing.
* **retry_secondary_threshold** (float) (optional): ratio of retry_timeout to switch to use secondary while failing.
  * Default value: `0.8`.
* **retry_type** (enum) (optional): How to wait next retry to flush buffer.
  * Available values: exponential_backoff, periodic
  * Default value: `exponential_backoff`.
* **retry_wait** (time) (optional): Seconds to wait before next retry to flush, or constant factor of exponential backoff.
  * Default value: `1`.
* **retry_exponential_backoff_base** (float) (optional): The base number of exponencial backoff for retries.
  * Default value: `2`.
* **retry_max_interval** (time) (optional): The maximum interval seconds for exponencial backoff between retries while failing.
* **retry_randomize** (bool) (optional): If true, output plugin will retry after randomized interval not to do burst retries.
  * Default value: `true`.
* **chunk_keys** () (optional): 
  * Default value: `[]`.


### \<secondary\> section (optional) (single)

* **@type** (string) (optional): 
  * Alias: type
* **buffer** () (optional): 
* **secondary** () (optional): 

## Copyright

* Copyright(c) 2017- Kenji Okimoto
* License
  * Apache License, Version 2.0
