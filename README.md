# vis-gpg

Edit [GPG](https://gnupg.org/) encrypted files in place with
[Vis](https://github.com/martanne/vis).

# Installation

See [Plugins](https://github.com/martanne/vis/wiki/Plugins) on the
Vis wiki.

# Usage

Files are automatically decrypted to memory on file open and encrypted
prior to writing back to the disk. Unencrypted contents exist solely in
memory and never touch the filesystem.
