from flask import Flask, request, jsonify, render_template
import sqlite3
from datetime import datetime

app = Flask(__name__)

# --- Database Setup ---
def init_db():
    conn = sqlite3.connect("database.db")
    cursor = conn.cursor()

    # Single table for all system metrics and info
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS system_metrics (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cpu_usage REAL,
            memory_usage REAL,
            disk_usage REAL,
            user_name TEXT,
            computer_name TEXT,
            os TEXT,
            ip_address TEXT,
            timestamp TEXT
        )
    ''')

    conn.commit()
    conn.close()


# --- Endpoint for client metrics and system info ---
@app.route('/stats', methods=['POST'])
def stats():
    data = request.json
    print("Received Metrics:", data)

    conn = sqlite3.connect("database.db")
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO system_metrics (cpu_usage, memory_usage, disk_usage, user_name, computer_name, os, ip_address, timestamp)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        data.get("cpu_usage"),
        data.get("memory_usage"),
        data.get("disk_usage"),
        data.get("user_name"),
        data.get("computer_name"),
        data.get("os"),
        data.get("ip_address"),
        data.get("timestamp", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    ))
    conn.commit()
    conn.close()

    return jsonify({"status": "success", "message": "Metrics stored successfully"}), 200


# --- Root endpoint redirects to dashboard ---
@app.route('/')
def index():
    return render_template('dashboard.html')

# --- Endpoint to view collected metrics ---
@app.route('/metrics', methods=['GET'])
def metrics():
    conn = sqlite3.connect("database.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM system_metrics ORDER BY id DESC LIMIT 10")
    rows = cursor.fetchall()
    conn.close()

    # Format into JSON
    metrics_list = [
        {
            "id": r[0], 
            "cpu_usage": r[1], 
            "memory_usage": r[2], 
            "disk_usage": r[3], 
            "user_name": r[4],
            "computer_name": r[5],
            "os": r[6],
            "ip_address": r[7],
            "timestamp": r[8]
        }
        for r in rows
    ]
    return jsonify(metrics_list)

# --- Dashboard endpoint ---
@app.route('/dashboard')
def dashboard():
    return render_template('dashboard.html')

# --- Endpoint to clear all metrics ---
@app.route('/clear-metrics', methods=['POST'])
def clear_metrics():
    try:
        conn = sqlite3.connect("database.db")
        cursor = conn.cursor()
        cursor.execute("DELETE FROM system_metrics")
        conn.commit()
        conn.close()
        return jsonify({"status": "success", "message": "All metrics cleared successfully"}), 200
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


if __name__ == "__main__":
    init_db()
    app.run(host="127.0.0.1", port=5000, debug=True)
