* create account:
```
nsc add account ACCOUNT_NAME_X
nsc edit account ACCOUNT_NAME_X --sk generate
```
* create user:
```
nsc add user --account ACCOUNT_NAME_X user_name_x
nsc generate creds -n user_name_x > user_name_x.creds
```
* save context:
```
nats context save externalServer \
  --server "nats://20.101.205.253:4222" \
  --nsc nsc://external/ACCOUNT_NAME_X/user_name_x
```
* select context:
```
nats context select user-one
```
* add a stream:
```
nats stream add --config ./natsStreamConf.json
```
* natsStreamConf.json: (is in this json where the subjects are defined)
```
{
  "name": "de_000000000002-organizational-structure-management",
  "subjects": [
    "de_000000000002-organizational-structure-management.business-units.post.1-0",
    "de_000000000002-organizational-structure-management.business-units.put.1-0",
    "de_000000000002-organizational-structure-management.business-units.delete.1-0"
  ],
  "retention": "limits",
  "max_consumers": -1,
  "max_msgs_per_subject": -1,
  "max_msgs": -1,
  "max_bytes": -1,
  "max_age": 0,
  "max_msg_size": -1,
  "storage": "file",
  "discard": "old",
  "num_replicas": 1,
  "duplicate_window": 120000000000,
  "sealed": false,
  "deny_delete": false,
  "deny_purge": false,
  "allow_rollup_hdrs": false,
  "allow_direct": false,
  "mirror_direct": false
}
```
* add a consumers:
```
nats consumer add de_000000000002-organizational-structure-management --config ./consumer-delete-POC.json
```
* consumer-delete-POC.json:
```
{
  "ack_policy": "explicit",
  "ack_wait": 30000000000,
  "deliver_policy": "all",
  "deliver_subject": "de_000000000002-organizational-structure-management_business-units_delete_1-0_POC",
  "deliver_group": "de_000000000002-organizational-structure-management_business-units_delete_1-0_POC",
  "durable_name": "de_000000000002-organizational-structure-management_business-units_delete_1-0_POC",
  "name": "de_000000000002-organizational-structure-management_business-units_delete_1-0_POC",
  "filter_subject": "de_000000000002-organizational-structure-management.business-units.delete.1-0",
  "max_ack_pending": 1000,
  "max_deliver": -1,
  "replay_policy": "instant",
  "num_replicas": 0
}
```
```
nats consumer add de_000000000002-organizational-structure-management --config ./consumer-post-POC.json
```
* consumer-post-POC.json:
```
{
  "ack_policy": "explicit",
  "ack_wait": 30000000000,
  "deliver_policy": "all",
  "deliver_subject": "de_000000000002-organizational-structure-management_business-units_post_1-0_POC",
  "deliver_group": "de_000000000002-organizational-structure-management_business-units_post_1-0_POC",
  "durable_name": "de_000000000002-organizational-structure-management_business-units_post_1-0_POC",
  "name": "de_000000000002-organizational-structure-management_business-units_post_1-0_POC",
  "filter_subject": "de_000000000002-organizational-structure-management.business-units.post.1-0",
  "max_ack_pending": 1000,
  "max_deliver": -1,
  "replay_policy": "instant",
  "num_replicas": 0
}
```
```
nats consumer add de_000000000002-organizational-structure-management --config ./consumer-put-POC.json
```
* consumer-put-POC.json:
```
{
  "ack_policy": "explicit",
  "ack_wait": 30000000000,
  "deliver_policy": "all",
  "deliver_subject": "de_000000000002-organizational-structure-management_business-units_put_1-0_POC",
  "deliver_group": "de_000000000002-organizational-structure-management_business-units_put_1-0_POC",
  "durable_name": "de_000000000002-organizational-structure-management_business-units_put_1-0_POC",
  "name": "de_000000000002-organizational-structure-management_business-units_put_1-0_POC",
  "filter_subject": "de_000000000002-organizational-structure-management.business-units.put.1-0",
  "max_ack_pending": 1000,
  "max_deliver": -1,
  "replay_policy": "instant",
  "num_replicas": 0
}
```
---
* Example: Publish 10 messages to 'de_000000000002-organizational-structure-management.business-units.put.1-0' topic.

```
nats pub de_000000000002-organizational-structure-management.business-units.put.1-0 "message {{.Count}} @ {{.TimeStamp}}" --count=10
```
* Example: Add a subscription to 'de_000000000002-organizational-structure-management_business-units_post_1-0_POC' consumer.

```
nats consumer sub de_000000000002-organizational-structure-management de_000000000002-organizational-structure-management_business-units_put_1-0_POC
```


