# Repo for my Linux tools

## [temp-zram](https://github.com/matiue/Linux-tools/blob/main/temp-zram.sh):
Just a script to activate zram temporary, considering:
1. For my setup there is no swap availabe and zram is used instead(I configured it that way intentionally, and also I have decreased the default swapiness) .
2. It will increase swappiness to make sure OOM killer wont work and make system more responsible.
3. Zram size is as size as memory.
4. As I dont use swap, zram can be used instead, I had over 30 GB Ram uasge on my 16 GB ram.
5. In my case that I dont have swap, the zram blocks my not be used by hibernate, this means i should use sleep instead.
6. I am using it on latest version of linux kernrl, that means latestes version of zram. so there is no need for multiple zram device.
7. The "trade of" here is the usage of cpu for compressing and decompressing, on modern cpus that is not going over 10 percent.


As I dont wanna have disk i/o I did not activate the writeback option (it writes incompressible pages into backing device BUT it can be automated to do it with cold pages with a cron). even activating it may be a better choice than storage swap files,and has less disk i/o.
