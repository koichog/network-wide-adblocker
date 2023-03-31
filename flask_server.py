import sys
import os
import requests
import subprocess
import logging
from flask import Flask, render_template_string, request, send_from_directory, jsonify
from flask_cors import CORS
from pathlib import Path


app = Flask(__name__)
CORS(app)

# Set up logging
log_file_path = '/var/www/html/blocklists/flask_server.log'  # Replace with the path to your log file
log_format = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

# Configure Flask logger
flask_handler = logging.FileHandler(log_file_path)
flask_handler.setLevel(logging.INFO)
flask_handler.setFormatter(log_format)
app.logger.addHandler(flask_handler)

# Configure Werkzeug logger
werkzeug_logger = logging.getLogger('werkzeug')
werkzeug_handler = logging.FileHandler(log_file_path)
werkzeug_handler.setFormatter(log_format)
werkzeug_logger.addHandler(werkzeug_handler)
werkzeug_logger.setLevel(logging.INFO)



@app.route('/restart_squid', methods=['POST'])
def restart_squid():
    restart_command = ['sudo', 'systemctl', 'restart', 'squid']
    subprocess.run(restart_command)
    return 'Squid is restarting', 200

@app.route('/flush_entries', methods=['POST'])
def truncate_access_log():
    access_log_path = '/var/log/squid/access.log'
    with open(access_log_path, 'w') as log_file:
        log_file.truncate(0)
    return 'Access.log truncated', 200


@app.route('/get_logs', methods=['GET'])
def get_logs():
    log_file = '/var/www/html/blocklists/flask_server.log'
    with open(log_file, 'r') as f:
        logs = f.readlines()
    return jsonify({"logs": logs})

@app.route('/flush_logs', methods=['POST'])
def flush_logs():
    with open('/var/www/html/blocklists/flask_server.log', 'w') as logs:
        logs.truncate(0)
    return 'Logs flushed', 200
    
@app.route('/update_main_blocklist', methods=['POST'])
def update_main_blocklist_url():
    blocklist_url = request.data.decode('utf-8')
    try:
        # Verify if the URL is valid and can be downloaded
        response = requests.get(blocklist_url)
        if response.status_code == 200:
            with open('/var/www/html/blocklists/main_blocklist.txt', 'w') as f:
                f.write(response.text)
            return 'OK', 200
        else:
            return 'Failed to download the blocklist', 400
    except Exception as e:
        print(e)
        return 'Error occurred', 500


@app.route('/custom_blocklist', methods=['GET'])
def get_custom_blocklist():
    return send_from_directory('/var/www/html/blocklists', 'custom_blocklist.txt')


@app.route('/update_custom_blocklist', methods=['POST'])
def save_custom_blocklist():
    content = request.data.decode('utf-8')
    with open('/var/www/html/blocklists/custom_blocklist.txt', 'w') as f:
        f.write(content)
    return 'OK', 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)

