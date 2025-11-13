linux tune


# Repo for my Linux tuning
- [x] Desktop tuning
- [ ] Web server tuining
- [ ] Postgress server tuning
- [ ] ML server tuning
- ...?


## [temp-tune-desktop](https://github.com/matiue/Linux-tools/blob/main/Linux-tune/temp-tune-desktop.sh):
Just a script to activate zram temporary, considering:
1. For my setup there is no swap availabe and zram is used instead(I configured it that way intentionally, and also I have decreased the default swapiness) .
2. It will increase swappiness to make sure OOM killer wont work and make system more responsible.
3. Zram size is as size as memory.
4. As I dont use swap, zram can be used instead, I had over 30 GB Ram uasge on my 16 GB ram.
5. In my case that I dont have swap, the zram blocks my not be used by hibernate, this means i should use sleep instead.
6. I am using it on latest version of linux kernrl, that means latestes version of zram. so there is no need for multiple zram device.
7. The "trade of" here is the usage of cpu for compressing and decompressing, on modern cpus that is not going over 10 percent.

8. page-cluster is lowered now :
If the kernel tries to swap large clusters at once, the CPU has to compress/decompress all those pages, even if the program only needs the first page immediately.
With vm.page-cluster = 0 (1 page per swap I/O):
Only the needed page is swapped in or out.
Avoids spending CPU on compressing/decompressing extra pages that may not be used immediately.
On disk swap, readahead is helpful because sequential I/O is much faster than random I/O.
In zram: all memory accesses are fast, so reading multiple pages at once doesn’t speed things up.
Lower page-cluster allows the kernel to swap pages more selectively, keeping memory usage more efficient.



As I dont wanna have disk i/o I did not activate the writeback option (it writes incompressible pages into backing device BUT it can be automated to do it with cold pages with a cron). even activating it may be a better choice than storage swap files,and has less disk i/o.

on my last check up (kernel 6.17.7) the recompression setting is not triggered atomic, it is a onetime trigger.(a cron can be a good setup for idle and huge pages to compress with a higher compress ratio)



resources:

zram
[archwiki](https://wiki.archlinux.org/title/Zram)
[kernel admin docs](https://docs.kernel.org/admin-guide/blockdev/zram.html)

page-cluster
[kernel docs](https://docs.kernel.org/admin-guide/sysctl/vm.html#page-cluster)
