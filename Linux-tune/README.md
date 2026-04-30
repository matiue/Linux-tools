linux tune


# Repo for my Linux tuning
- [ ] Desktop tuning
    - [x] zram cofig as swap
    - [x] swapiness at highest amount
    - [x] disable page-cluster 
    - [ ] ...
- [ ] Web server tuining
- [ ] Postgress server tuning
- [ ] ML server tuning
- ...?


## [temp-tune-desktop](https://github.com/matiue/Linux-tools/blob/main/Linux-tune/temp-tune-desktop.sh):
Arch Linux is often regarded as a "raw" Linux distribution unlike many other distros, it comes without any built-in tuning or performance tweaks. This script is an attempt to introduce performance optimizations tailored for desktop use on Arch Linux. In the future, similar scripts will also be provided for various server use cases.
some considerations:

---

1. **Swap and zram setup** – On my system, no traditional swap is available; I use zram instead (configured intentionally, and I've also lowered the default swappiness value).

2. **Swappiness tuning** – I increase swappiness to help prevent the OOM killer from being triggered, making the system more responsive under memory pressure.

3. **Zram size** – The zram device is sized equal to the amount of physical memory.

4. **Memory usage** – Since I don't use disk swap, zram acts as its replacement. I've seen over 30 GB of RAM usage on my 16 GB system (thanks to compression).

5. **Hibernation** – Because I have no disk swap, zram cannot be used for hibernation. That means I use suspend-to‑RAM (sleep) instead.

6. **Kernel version** – I'm running the latest Linux kernel, which includes the newest zram implementation. This means there's no need for multiple zram devices (a single one is sufficient).

7. **CPU trade‑off** – The cost of using zram is CPU time for compression and decompression. On modern CPUs, this typically stays below 10%.

8. **page-cluster lowering** – I've reduced `vm.page-cluster`.  
   - If the kernel swaps large clusters at once, the CPU has to compress/decompress all those pages – even if the program only needs the first page immediately.  
   - With `vm.page-cluster = 0` (1 page per swap I/O):  
     - Only the needed page is swapped in or out.  
     - This avoids wasting CPU on compressing/decompressing extra pages that may not be used right away.  
   - On disk swap, readahead is beneficial because sequential I/O is much faster than random I/O.  
   - With zram, all memory accesses are fast, so reading multiple pages at once doesn't improve performance.  
   - Lowering `page-cluster` lets the kernel swap pages more selectively, keeping memory usage more efficient.

9. **Writeback option** – I don't want any disk I/O, so I have not enabled the writeback feature (which writes incompressible pages to a backing store). That said, writeback could be automated for cold pages using a cron job. Even if enabled, it would still cause less disk I/O than traditional swap files.

10. **Recompression** – On my last check with kernel 6.17.7, the recompression setting is not triggered atomically – it's a one‑time trigger. A cron job can be a good way to periodically recompress idle or huge pages using a higher compression ratio.


resources:

zram
[archwiki](https://wiki.archlinux.org/title/Zram)
[kernel admin docs](https://docs.kernel.org/admin-guide/blockdev/zram.html)

page-cluster
[kernel docs](https://docs.kernel.org/admin-guide/sysctl/vm.html#page-cluster)
