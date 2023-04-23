const url = 'https://' + window.location.hostname + ':8081';


//flush access.log
document.getElementById('flushEntries').onclick = async () => {
    await fetch(url + '/flush_entries', {
        method: 'POST',
    });
    alert('Access.log truncated!');
};

//restart squid 
document.getElementById('restartSquid').onclick = async () => {
    await fetch(url + '/restart_squid', {
        method: 'POST',
    });
    alert('Squid is restarting!');
};

// Load the custom blocklist
async function loadCustomBlocklist() {
    const response = await fetch(url + '/custom_blocklist');
    const blocklist = await response.text();
    document.getElementById('customBlocklist').value = blocklist;
}
loadCustomBlocklist();


//update main blocklist file
document.getElementById('updateMainBlocklistUrl').onclick = async () => {
    const mainBlocklistUrl = document.getElementById('mainBlocklistUrl').value;
    await fetch(url + '/update_main_blocklist', {
        method: 'POST',
        body: mainBlocklistUrl,
        headers: {
            'Content-Type': 'text/plain'
        }
    });
    alert('Main blocklist URL updated!');
};


// Save the custom blocklist
document.getElementById('saveCustomBlocklist').onclick = async () => {
    const customBlocklist = document.getElementById('customBlocklist').value;
    await fetch(url + '/update_custom_blocklist', {
        method: 'POST',
        body: customBlocklist,
        headers: {
            'Content-Type': 'text/plain'
        }
    });
    alert('Custom blocklist saved!');
};

// load logs
async function fetchLogs() {
    const response = await fetch(url + '/get_logs');
    const data = await response.json();
    const logs = data.logs.join('');
    const logsArray = logs.split('\n');
    let logHtml = '';
    logsArray.forEach(log => {
        logHtml += `<tr><td>${log}</td></tr>`;
    });
    document.getElementById('logs').innerHTML = logHtml;
}

document.getElementById('getLogs').onclick = fetchLogs;
document.getElementById('goToEntries').onclick = () => {
            window.location.href = 'index.html';
        };

//flush logs
document.getElementById('flushLogs').onclick = async () => {
     await fetch(url + '/flush_logs', {
         method: 'POST',
         headers: {
             'Content-Type': 'text/plain'
         }
     });
     alert('Flask logs flushed!');
     fetchLogs();
 };

