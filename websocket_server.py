import math
import asyncio
import websockets
import json
import os

async def read_access_log(websocket, path):
    log_file = '/usr/local/squid/var/logs/access.log'
    last_position = 0

    while True:
        with open(log_file, 'r') as file:
            file.seek(last_position)
            new_lines = file.readlines()
            last_position = file.tell()

        parsed_lines = [parse_access_log_line(line) for line in new_lines if line.strip()]

        if parsed_lines:
            await websocket.send(json.dumps(parsed_lines))

        await asyncio.sleep(5)

def parse_access_log_line(line):
    parts = line.split()
    return {
        'timestamp': math.floor(float(parts[0])),
        'ip': parts[2],
        'url': parts[6],
        'status': parts[3]
    }


start_server = websockets.serve(read_access_log, '0.0.0.0', 8080)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
