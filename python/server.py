from flask import Flask, render_template
from flask_socketio import SocketIO, emit

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

totalSteps = 0
totalSpeed = 0

@app.route('/')
def index():
    return render_template('index.html')

@socketio.on('step', namespace='/test')
def steps_handler(message):
    print(message)
    global totalSteps
    totalSteps += message
    emit('totalPosition', totalSteps, broadcast=True)

@socketio.on('speed', namespace='/test')
def speed_handler(message):
    print(message)
    global totalSpeed
    totalSpeed  = message
    emit('totalSpeed', totalSpeed, broadcast=True)

@socketio.on('resetPosition', namespace='/test')
def reset_Handler(message):
    print(message)
    global totalSteps
    totalSteps = 0
    emit('totalPosition', totalSteps, broadcast=True)

@socketio.on('pull', namespace='/test')
def reset_Handler(message):
    emit('totalPosition', totalSteps)
    emit('totalSpeed', totalSpeed)

@socketio.on('connect', namespace='/test')
def test_connect():
    print("ClientConnected")




@socketio.on('disconnect', namespace='/test')
def test_disconnect():
    print('Client disconnected')

if __name__ == '__main__':
    socketio.run(app)