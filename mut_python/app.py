from flask import Flask, jsonify, request
import os

app = Flask(__name__)


@app.route('/')
def hello_world():
    return 'AMON-MUT is working!'


@app.route('/api/appRunning')
def api_app_running():
    device_id = request.args.get("device_id")
    return jsonify({"device_id" : device_id})


@app.route('/api/getAmonConfig')
def api_get_amon_config():
    is_disabled = os.environ["DISABLE_AMON"] == "TRUE"
    return jsonify({"is_disabled" : is_disabled})


if __name__ == '__main__':
    app.run()
