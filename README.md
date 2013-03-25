trash-cli (bash,zsh)
======================

    $ git clone https://github.com/emanon-was/trash-cli.git

Prepare
------
Add trash-cli/bin to env[PATH].

    $ export PATH=/path/to/trash-cli/bin:$PATH

or

Load functions to shell(bash,zsh).

    $ source /path/to/trash-cli/share/trash-cli/trash-cli.sh

Usage
------
### trash-put ###
Move the files to Trash, and create trashinfo file.

    $ trash-put test1.txt test2.txt test3.txt test4.txt

### trash-list ###
Read trashinfo files.

    $ trash-list
    2013-03-11 08:37:49 /home/emanon/test1.txt
    2013-03-12 08:37:49 /home/emanon/test2.txt
    2013-03-15 08:37:49 /home/emanon/test3.txt
    2013-03-21 08:37:49 /home/emanon/test4.txt

All arguments are passed to the sort command to be executed at the end.

    $ trash-list -r
    2013-03-21 08:37:49 /home/emanon/test4.txt
    2013-03-15 08:37:49 /home/emanon/test3.txt
    2013-03-12 08:37:49 /home/emanon/test2.txt
    2013-03-11 08:37:49 /home/emanon/test1.txt

### trash-restore ###
Restore the files to previous position.

    $ trash-restore
      1 2013-03-11 08:37:49 /home/emanon/test1.txt
      2 2013-03-12 08:37:49 /home/emanon/test2.txt
      3 2013-03-15 08:37:49 /home/emanon/test3.txt
      4 2013-03-21 08:37:49 /home/emanon/test4.txt
    What file to restore [1..4]: 1 3

You can choose some.

### trash-empty ###
The default is to delete all.

    $ trash-empty
    2013-03-11 08:37:49 /home/emanon/test1.txt
    2013-03-12 08:37:49 /home/emanon/test2.txt
    2013-03-15 08:37:49 /home/emanon/test3.txt
    2013-03-21 08:37:49 /home/emanon/test4.txt
    Delete these 4 files really? [y/n] y

Delete the files from N day before.

    $ trash-empty 7
    2013-03-11 08:37:49 /home/emanon/test1.txt
    2013-03-12 08:37:49 /home/emanon/test2.txt
    Delete these 2 files really? [y/n] y

### trash-remove ###
Delete the files that match the pattern.

    $ trash-remove "*"
    2013-03-26 04:46:59 /home/emanon/test1.txt
    2013-03-26 04:46:59 /home/emanon/test2.txt
    2013-03-26 04:46:59 /home/emanon/test3.txt
    2013-03-26 04:46:59 /home/emanon/test4.txt
    Delete these 4 files really? [y/n] y

If more than one pattern

    $ trash-remove "test3*" "test1*"
    2013-03-26 04:46:59 /home/emanon/test1.txt
    2013-03-26 04:46:59 /home/emanon/test3.txt
    Delete these 2 files really? [y/n] y


Warning
------
Depends on Bash or Zsh.

