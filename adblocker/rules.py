import re

def load_rules(filename):
    with open(filename, 'r') as f:
        lines = f.read().splitlines()
    return [re.compile(line) for line in lines if line and not line.startswith('!')]

def should_block(request_url, rules):
    for rule in rules:
        if rule.search(request_url):
            return True
    return False

