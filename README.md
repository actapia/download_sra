# SRA runs downloader

This is a little tool I wrote to download sequence reads in fastq format from the Sequence Read Archive (SRA) without losing quality information.

## Requirements

This application has been tested with the following software versions. If you have similar versions, it may still work, but such configurations are untested.

* CPython 3.11
* lxml 4.9.2
* requests 2.28.2
* Bash 5.2.2

## Usage

### With arguments

The script will accept any number of SRA links or accessions as command line arguments. For example,

```bash
bash download_sra.sh https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser&acc=SRR2321388&display=metadata
```

or

```bash
bash download_sra.sh SRR2321388
```

If your SRA record is associated with only one run, you can alternatively provide the link to the SRA entry. Hence, the following works.

```bash
bash download_sra.sh https://www.ncbi.nlm.nih.gov/sra/SRX1214077[accn]
```

or

```bash
bash download_sra.sh SRX1214077
```

### From stdin

If you need to download many sequence files, you may find it easier to provide a list via standard input. For example,

```bash
echo -e "SRX1214077\nSRX1214076" | bash download_sra.sh
```

Note that `download_sra.sh` only reads from standard input if no links/accessions are provided as command-line arguments.

### Running with multiple jobs

You can provide the `-j` option to `download_sra.sh` to make use of multiple processor cores.

```bash
bash download_sra.sh -j 4 SRX1214076
```