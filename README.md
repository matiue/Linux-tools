# Repo for my Linux tools

## temp-zram:
script to activate zram temporary, considering:
1. For my setup there is no swap availabe and zram is used instead.
2. It will increase swappiness to make sure OOM killer wont work and make system more responsible.
3. Zram size is as size as memory.
4. As I dont use swap, zram can be used instead, I had over 30 GB Ram uasge on my 16 GB ram.
5. In my case that I dont have swap, the zram blocks my not be used by hibernate, this means i should use sleep instead.
