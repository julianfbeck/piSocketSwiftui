from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import RPi.GPIO as GPIO
import time


app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

totalSpeed = 0

stop = False
last_step = 0

total_step = 0
last_speed = 0

control_pins = [17,22,27,23]
halfstep_seq = [
    [1,0,0,0],
    [1,1,0,0],
    [0,1,0,0],
    [0,1,1,0],
    [0,0,1,0],
    [0,0,1,1],
    [0,0,0,1],
    [1,0,0,1]
]

def setup():
    GPIO.setmode(GPIO.BCM)
    for pin in control_pins:
        GPIO.setup(pin, GPIO.OUT)
        GPIO.output(pin, 0)

def move_stepps(steps, speed=-1):
    global last_step
    global control_pins
    global last_speed
    global total_step
    global stop

    #check if new speed is set
    if(speed > 0):
        last_speed = speed

    #check direction
    if(steps > 0):
        for halfstep in range(steps*2):

            #check if step ist a full step
            if halfstep%2 == 0:

                #count total steps
                total_step += 1
                if(total_step >= 50):
                    total_step = 0
                
                #interrupt
                if stop: 
                    #GPIO.cleanup()
                    return 

            #save which step was the last one
            last_step += 1
            if last_step == 8 : 
                last_step = 0

            for pin in range(4):
                GPIO.output(control_pins[pin], halfstep_seq[halfstep][pin])
            #GPIO.output(control_pins, halfstep_seq[last_step])
            
            #speed is in 1/min => (1min) splittet in halfsteps for a ration (=> 100) per roation
            time.sleep(60/(last_speed*100))
    else:
        for halfstep in range(abs(steps)*2):
            if halfstep%2 == 0:
                total_step -= 1
                if(total_step <= 0):
                    total_step = 50
                if stop: 
                    #GPIO.cleanup()
                    return 
            last_step -= 1
            if last_step == 0 : 
                last_step = 7
            #GPIO.output(control_pins, halfstep_seq[last_step])
            for pin in range(4):
                GPIO.output(control_pins[pin], halfstep_seq[halfstep][pin])
            time.sleep(60/(last_speed*100))

    #GPIO.cleanup()
    print("done")


@app.route('/')
def index():
    return render_template('index.html')

@socketio.on('step', namespace='/test')
def steps_handler(new_steps):
    print(new_steps)
    global total_step
    #total_step += new_steps
    move_stepps(new_steps, 60)
    emit('totalPosition', total_step, broadcast=True)

@socketio.on('speed', namespace='/test')
def speed_handler(message):
    print(message)
    global totalSpeed
    totalSpeed  = message
    emit('totalSpeed', totalSpeed, broadcast=True)

@socketio.on('resetPosition', namespace='/test')
def reset_Handler(message):
    print(message)
    global total_step
    total_step = 0
    emit('totalPosition', total_step, broadcast=True)

@socketio.on('stop', namespace='/test')
def reset_Handler(message):
    print(message)
    global stop
    stop = True
    emit('stop', 1, broadcast=True)

@socketio.on('go', namespace='/test')
def reset_Handler(message):
    print(message)
    global stop
    stop = False
    emit('stop', 0, broadcast=True)

@socketio.on('pull', namespace='/test')
def reset_Handler(message):
    emit('totalPosition', total_step)
    emit('totalSpeed', totalSpeed)

@socketio.on('connect', namespace='/test')
def test_connect():
    print("ClientConnected")




@socketio.on('disconnect', namespace='/test')
def test_disconnect():
    print('Client disconnected')

if __name__ == '__main__':
    setup()
    socketio.run(app, host='0.0.0.0', port=8080)




def move_grad(grad, speed):
    #calculate steps to move 
    steps_to_do = grad * 7,2

    move_stepps(int(steps_to_do), speed)
    print("done")

def to_abs_grad(grad, speed):
    global total_step

    #check  input (0-359)
    if(grad <= 359 and grad >=0):
        #calc steps from zeropoint ( where total_setp is zero)
        steps_from_zero = grad * 7,2

        #check direction to move
        if steps_from_zero > total_step:
            move_stepps(int(steps_from_zero)-total_step, speed)
        else:
            move_stepps(total_step - int(steps_from_zero), speed)

        print("done")
    else:
        print("wrong")


def halt():
    global last_step
    global control_pins

    #set last halfstep to prevent the motor vom moving
    GPIO.output(control_pins, halfstep_seq[last_step])
    print("done")

def release():
    GPIO.cleanup()
    print("done")