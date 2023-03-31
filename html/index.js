const tableBody = document.querySelector('#accessTable tbody');
const ipAddress = window.location.hostname;
const url = 'ws://' + ipAddress + ':8080/';
const ws = new WebSocket(url);


ws.onmessage = (message) => {
    const dataList = JSON.parse(message.data);
    if (Array.isArray(dataList)) {
        for (const data of dataList) {
            if (data.ip && data.ip !== '::') {
                addTableRow(data.timestamp, data.ip, data.url, data.status);
            }
        }
    } else {
        if (dataList.ip && dataList.ip !== '::') {
            addTableRow(dataList.timestamp, dataList.ip, dataList.url, dataList.status);
        }
    }
};


const formatDate = (timestamp) => {
    const date = new Date(timestamp * 1000);
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    return `${day}/${month}/${year} ${hours}:${minutes}`;
   };

const addTableRow = (timestamp, ip, url, status) => {
    if (url.includes("mozilla") || url.includes("firefox") || url.includes("error:accept-client-connection") || url.includes("getpocket")) {
        return;
    }

    const formattedDate = formatDate(timestamp);

    const row = document.createElement('tr');
    const dateCell = document.createElement('td');
    const ipCell = document.createElement('td');
    const urlCell = document.createElement('td');


    dateCell.textContent = formattedDate;
    ipCell.textContent = ip;
    urlCell.textContent = url;


    if (status === 'TCP_TUNNEL/200') {
        row.style.color = 'green';
    } else {
        row.style.color = 'red';
    }

    row.appendChild(dateCell);
    row.appendChild(ipCell);
    row.appendChild(urlCell);
    tableBody.insertBefore(row, tableBody.firstChild);
};

document.getElementById('goToConfig').onclick = () => {
            window.location.href = 'config.html';
        };
