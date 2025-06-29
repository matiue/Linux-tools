# Repo for my Linux tools

## temp-zram:
script to activate zram temporary, considering:
1. there is no swap availbe and zram is used instead.
2. it will increase swappiness to make sure OOM killer wont work
3. zram size is as size as memory
