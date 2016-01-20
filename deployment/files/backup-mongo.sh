#!/bin/bash

export AZURE_STORAGE_ACCOUNT="sanglucciarchives"
export AZURE_STORAGE_ACCESS_KEY="ypzQzzGE1T3lu2DdsfZwcBD035KSqP+K2qNA9WytZqZY7Hug7gw4tGjTXjwdP8pEn1bSwK/TQWql8YUSrK7cXg=="

FILE="`hostname -f`-`date +"%Y%m%d-%H%M"`.db.gz"

mongodump --archive=$FILE --gzip --oplog || exit

azure storage blob upload $FILE backups $FILE

rm -rf $FILE