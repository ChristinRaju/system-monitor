# System Monitor

A comprehensive system monitoring application that collects, stores, and visualizes system metrics with a web dashboard.

## Project Structure

```
system-monitor/
│
├── server/
│   ├── app.py            # Flask server with RESTful API
│   ├── database.db       # SQLite database (auto-created)
│   ├── requirements.txt  # Python dependencies
│   └── templates/
│       └── dashboard.html # Web dashboard with charts
│
├── client/
│   └── collect.ps1       # PowerShell client script
│
└── README.md             # Project documentation
```

## Server Setup

1. Navigate to the server directory:
   ```bash
   cd server
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Run the Flask server:
   ```bash
   python app.py
   ```

The server will start on `http://localhost:5000`

## Client Usage

1. Make sure the server is running
2. Run the PowerShell script:
   ```powershell
   .\client\collect.ps1
   ```

3. Optional: Specify a different server URL:
   ```powershell
   .\client\collect.ps1 -ServerUrl "http://your-server-ip:5000"
   ```

## Web Dashboard

Access the dashboard at `http://localhost:5000/` to view:

- **Interactive Charts**: CPU, memory, and disk usage over time
- **Recent Metrics Table**: Detailed view of all collected data
- **Clear Metrics Button**: Remove all stored metrics (top right of table)

## API Endpoints

- `GET /` - Web dashboard (redirects to `/dashboard`)
- `GET /dashboard` - Web dashboard interface
- `POST /stats` - Submit new system metrics
- `GET /metrics` - Retrieve stored metrics (JSON format)
- `POST /clear-metrics` - Clear all metrics from database

## Features

- **Real-time Metrics Collection**: CPU, memory, and disk usage monitoring
- **System Information**: User, computer name, OS, and IP address detection
- **Web Dashboard**: Interactive charts and data visualization using Chart.js
- **Database Storage**: SQLite database for persistent metric storage
- **RESTful API**: Complete API endpoints for data management
- **Clear Metrics**: One-click clearing of all collected metrics





Here are the PowerShell commands you can run directly in your VS Code terminal:

**To start the Flask server:**

`cd server
python app.py`

**To collect and send metrics (in a new terminal):**

`cd client
.\collect.ps1`

**To test API endpoints:**

`# Get all metrics
curl http://localhost:5000/metrics

# Clear all metrics
curl -X POST http://localhost:5000/clear-metrics`

The server is already running on http://127.0.0.1:5000 and you can access the web dashboard by opening that URL in your browser.
