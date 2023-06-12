# backup-scripts

Various backup scripts we use for Perthchat.org!


## Usage

[media-store_snapshot.sh](./media-store_snapshot.sh) is a backup script that requires you to have a MooseFS storage system. It uses the snapshotting feature in MooseFS.

[postgresql_dump.sh](postgresql_dump.sh) script works with a patroni/postgresql cluster and picks a database node that's in 'replica' mode to reduce load on the current leader node.

These scripts are run via crontab like so:
```
# Perthchat.org - Make a daily MooseFS snapshot of the media-store, and do a Postgresql dump
0 4 * * * /usr/bin/bash /home/backup/media-store_snapshot.sh
0 4 * * * /usr/bin/bash /home/backup/postgresql_dump.sh
```

## License

Copyright 2023 Michael Collins

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.