## megaup.sh

### bash script for downloading megaup.net files

##### Download single file from megaup

```bash
./megaupnet.sh url
```

##### Batch-download files from URL list (url-list.txt must contain one megaup.net url per line)

```bash
./megaupnet.sh url-list.txt
```

##### Example:

```bash
./megaupnet.sh https://megaup.net/5uFry/Gillette_,_the_best_a_man_can_get.wav
```
### Requirements: `coreutils`, `curl`, `grep`, `sed`
