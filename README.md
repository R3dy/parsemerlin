Parse through Merlin agent logs
===============================

Extracts the important information about commands and stores them in an array of hash objects.  Give it a `URL`, `endpoint` and `basicauth` creds and it will send them off to a remote server for further processing.

## Installation
```
gem install parsemerlin
```

Run the executable with `-h` for a help menu
```
parsemerlin -h
parsemerlin version: 0.1 - updated: 04/26/2022

    -f, --file [File Path]              The agent log file you want to parse
    -i, --id [String]                   Agent ID
    -t, --target [String]               Target server to POST results
    -e, --endpoint [String]             Endpoint on target server
    -a, --auth [String]                 Userame:Password for basic authenticaiton
    -v, --verbose                       Enabled verbose output
```

## Basic usage
```
parsemerlin -t reportingserver.com -e /path/to/endpoint -a "username:password" -f agent.log -i fooidentifystring
```
