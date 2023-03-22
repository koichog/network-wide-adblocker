if __name__ == "__main__":
    import sys
    from pathlib import Path
    sys.path.insert(0, str(Path(__file__).parent))

from mitmproxy import ctx, http
from rules import *

rules_file = "/home/pi/network-wide-adblocker/rules/easylist.txt"
blocking_rules = load_rules(rules_file)

def request(flow: http.HTTPFlow):
    if should_block(flow.request.url, blocking_rules):
        ctx.log.info(f"Blocking: {flow.request.url}")
        flow.response = http.HTTPResponse.make(403, b"Blocked by adblocker", {"Content-Type": "text/html"})
    else:
        ctx.log.info(f"Allowing: {flow.request.url}")

