import re
from mitmproxy import ctx, http
from pathlib import Path
from adblockparser import AdblockRules

rules_file = Path(__file__).parent / "../rules/easylist.txt"

def load_rules(filename):
    with open(filename, 'r') as f:
        raw_rules = f.readlines()
    return AdblockRules(raw_rules)

blocking_rules = load_rules(rules_file)

def should_block(request_url, rules):
    return rules.should_block(request_url)

def request(flow: http.HTTPFlow):
    if should_block(flow.request.url, blocking_rules):
        ctx.log.info(f"Blocking: {flow.request.url}")
        flow.response = http.HTTPResponse.make(403, b"Blocked by adblocker", {"Content-Type": "text/html"})
    else:
        ctx.log.info(f"Allowing: {flow.request.url}")
