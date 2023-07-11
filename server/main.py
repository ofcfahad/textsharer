import firebase_admin
from firebase_admin import credentials, auth
from flask import Flask, request, jsonify
import jwt
import json

app = Flask(__name__)

credentialfile = credentials.Certificate('fahad_s_textsharer_admin_sdk.json')
firebase_admin.initialize_app(credentialfile)


def printx2(message):
    print(message, flush=True)


def replace_spaces_with_underscores(input_string):
    return input_string.replace(' ', '_')


async def register_device(id, name, icon):
    try:
        email = replace_spaces_with_underscores(f'{name}@textsharer.app')
        device = auth.create_user(email=email, password=id, display_name=name)
        doc_id = device.uid
        custom_claims = {
            'deviceId': id,
            'deviceIcon': icon
        }
        auth.set_custom_user_claims(doc_id, custom_claims)
        auth.update_user(doc_id,
                         custom_claims=custom_claims)
        return device
    except Exception as e:
        print('Error registering device:', e)
        raise e


def get_device_data(doc_id):
    try:
        user = auth.get_user(doc_id)
        device_id = user.custom_claims.get('deviceId')
        device_icon = user.custom_claims.get('deviceIcon')
        return {'deviceId': device_id, 'deviceIcon': device_icon}
    except:
        print('An exception occurred')


@app.route('/registerDevice', methods=['POST'])
async def registerDevice():
    try:
        request_data = request.get_json()
        device_id = request_data['deviceId']
        device_name = request_data['deviceName']
        device_icon = request_data['deviceIcon']
    except KeyError:
        return jsonify({'error': 'deviceId is missing'}), 400
    try:
        device = await register_device(device_id, device_name, device_icon)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

    return jsonify({f'device': f'{device}'}), 200


@app.route('/getDeviceCustomData', methods=['POST'])
async def getDeviceData():
    try:
        request_data = request.get_json()
        document_id = request_data['documentId']
    except KeyError:
        return jsonify({'error': 'deviceId is missing'}), 400
    try:
        device_data = get_device_data(document_id)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

    return jsonify(device_data), 200


if __name__ == '__main__':
    app_port = 5000
    app.run(host='0.0.0.0', port=app_port)
