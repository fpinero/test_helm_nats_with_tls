# How to use scripts for generating nats accounts, streams and subjects
* <b>script for generating nats accounts</b>

Usage ./add_nats_account_and_user.sh account
```
add_nats_account_and_user.sh es-0000000129
```

The scrip generates:
* an user for the account following the naming convention
* a secret in the keyvault including the account and user
* creates the NATS account
* creates the NATS user
* saves context
* pushes the account to the server using TLS
<br/><br/>
* <b>script for generating nats streams and subjects</b>

Usage ./add_nats_streams_and_subjects.sh StreamConf.json consumer.json
```
./add_nats_streams_and_subjects.sh natsStreamConf.json consumer-delete-POC.json consumer-post-POC.json consumer-put-POC.json
```

* The script uses the first json file provided in arguments for generating the stream. <br/> 
* The subsequent json files provided in arguments are used for generating the consumers. <br>
* Examples of stream and consumer json files are provided for reference.
* The script shows the current context and wait for 10 seconds just in case the user would want to abort the script to select a different context before run the script again.<br/>

The source of both scripts contain enough comments for adjusting them to use the scripts with a different NATS server, different operator or different key vault. <br /><br />
Detailed info about the nats and nsc commands used by the scripts has been posted [here](./info_for_creating_the_scripts.md)

# How to test it

Add a subscription to 'de_000000000002-organizational-structure-management_business-units_post_1-0_POC' consumer.

```
nats consumer sub de_000000000002-organizational-structure-management de_000000000002-organizational-structure-management_business-units_put_1-0_POC
```

Press CTRL+Z to send the consumer to background<br />

Publish 10 messages to 'de_000000000002-organizational-structure-management.business-units.put.1-0' topic.

```
nats pub de_000000000002-organizational-structure-management.business-units.put.1-0 "message {{.Count}} @ {{.TimeStamp}}" --count=10
``` 
run 
````
fg
````
to bring to the front the suspended consumer and it will show up the arriving messages published
```
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 206 / str seq: 36 / pending: 0
message 16 @ 2023-02-21T16:37:27+01:00
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 212 / str seq: 42 / pending: 0
message 22 @ 2023-02-21T16:37:27+01:00
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 216 / str seq: 46 / pending: 0
message 26 @ 2023-02-21T16:37:27+01:00
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 218 / str seq: 48 / pending: 0
message 28 @ 2023-02-21T16:37:27+01:00
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 219 / str seq: 49 / pending: 0
message 29 @ 2023-02-21T16:37:27+01:00
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 221 / str seq: 51 / pending: 0
message 31 @ 2023-02-21T16:37:28+01:00
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 222 / str seq: 52 / pending: 0
message 32 @ 2023-02-21T16:37:28+01:00
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 226 / str seq: 56 / pending: 0
message 36 @ 2023-02-21T16:37:28+01:00
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 227 / str seq: 57 / pending: 0
message 37 @ 2023-02-21T16:37:28+01:00
[16:37:51] subj: de_000000000002-organizational-structure-management.business-units.put.1-0 / tries: 1 / cons seq: 228 / str seq: 58 / pending: 0
message 38 @ 2023-02-21T16:37:28+01:00
```
