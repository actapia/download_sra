import argparse
import requests
import re

from urllib.parse import urlparse, parse_qs

import lxml.etree

sra_url_template = "https://www.ncbi.nlm.nih.gov/sra/{}"
srr_url_template = ("https://trace.ncbi.nlm.nih.gov/Traces/?view=run_browser"
                    "&acc={}&display=data-access")
run_new_url = "https://trace.ncbi.nlm.nih.gov/Traces/sra-db-be/run_new"

html_ns = {
    "x": "http://www.w3.org/1999/xhtml"
}

def handle_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("url", type=urlparse)
    args = parser.parse_args()
    if not args.url.netloc:
        if args.url.path.startswith("SRX"):
            args.url = urlparse(sra_url_template.format(args.url.path))
        if args.url.path.startswith("SRR"):
            args.url = urlparse(srr_url_template.format(args.url.path))
    return args

sra_regex = re.compile(r"/sra/SRX.*")

def main():
    args = handle_arguments()
    srr_link = args.url
    #embed()
    if sra_regex.match(args.url.path):
        # Get actual SRR link.
        resp = requests.get(args.url.geturl())
        tree = lxml.etree.fromstring(resp.content)
        table_links = tree.xpath(
            ("//x:tr[@class='sra-run-list-header']/../../x:tbody"
             "/x:tr/x:td[1]/x:a"),
            namespaces=html_ns
        )
        assert len(table_links) == 1
        srr_link = urlparse(table_links[0].attrib["href"])._replace(
            scheme="https",
        )
        #embed()
    qs = parse_qs(srr_link.query)
    acc = qs.get("acc", qs.get("run"))
    assert acc
    resp = requests.get(run_new_url, params={"acc": acc[0]})
    tree = lxml.etree.fromstring(resp.content)
    print(acc[0])
    print(
        tree.xpath(
            "//SRAFile[@semantic_name='SRA Normalized']"
        )[0].attrib["url"]
    )

if __name__ == "__main__":
    main()
