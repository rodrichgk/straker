import cv2 #Import CV2 
import numpy as np #Import Numpy
from adafruit_servokit import ServoKit #Import Servo driver library
kit = ServoKit(channels=16) #Define instance of Servo library
kit.servo[0].set_pulse_width_range(600, 2610)   #Set Minimum & Maximum positon of X axis Servo
kit.servo[1].set_pulse_width_range(1102, 2170)    #Set Minimum & Maximum positon of Y axis Servo
cap = cv2.VideoCapture(0) #Catpure video from camera
Ht = 320 #Defined Height of frame
Wd = 480 #Defined Width of Frame
cap.set(3, Wd) #Set frame Width
cap.set(4, Ht) #Set frame height
_, frame = cap.read() #Store captured frame of camera to variable "frame"
rows, cols, ch = frame.shape #Get frame size 
x_medium = int(cols / 2) #Initialize horizontal position 
y_medium = int(rows / 2) #Initialize vertical positon

x_center = int(cols / 2) #Initialize Horizontal center position
y_center = int(rows / 2) #Initialize Vertical center position
x_position = 90 # centre posito of servo 
y_position = 90 # centre posito of servo
x_band = 50
y_band = 50
#Loop
while True:
    _, frame1 = cap.read() #Store Video snap in varialble "frame1"
    frame2 = cv2.flip(frame1,-1) # Flip image vertically
    frame2 = cv2.flip(frame1, 0) # flip image vertically
    hsv_frame2 = cv2.cvtColor(frame2, cv2.COLOR_BGR2HSV)
    #blurred_frame = cv2.GaussianBlur(frame1, (5, 5), 0)
#Red Colour
    low_red = np.array([163,74,30]) #low HSV value for Red objects
    high_red = np.array([179,255,255]) # High HSV value for Red objects
    red_mask = cv2.inRange(hsv_frame2,low_red,high_red) # Apply Masking to image using low & Hign red masking value
    red = cv2.bitwise_and(frame2,frame2,mask=red_mask) # Anding of original frame & 
#Contors
    contours_red, _ = cv2.findContours(red_mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_NONE) # Findig Contours
    contours = sorted(contours_red, key=lambda x:cv2.contourArea(x), reverse=True) # Arrange Contours in Assending
    for cnt in contours: # Draw rectangle on First contors on image
        (x,y,w,h) = cv2.boundingRect(cnt)
        cv2.rectangle(frame2, (x , y) , (x + w, y + h) , (0, 255, 0), 2) # Getting Position of rectangle & line colour & thickness
        break # Break loop to draw only one rectangle. if comment we get all red object rectangle
    for cnt in contours:
        (x,y,w,h) = cv2.boundingRect(cnt)
        x_medium = int((x + x + w) / 2) # Checking horizontal center of red object & save to variable
        y_medium = int((y + y + h) / 2) # Checking Vertical center of red object & save to variable
        break
    cv2.line(frame2, (x_medium, 0), (x_medium, Ht), (0, 255, 0), 2) #Draw horizontal centre line of red object
    cv2.line(frame2, (0, y_medium), (Wd, y_medium), (0, 255, 0), 2) #Draw Vertical centre line of red object
    cv2.imshow("IN Frame", frame2) #Printing frame with rectangle &  lines
    # Move Horizontal Servo servo motor
    if x_medium < x_center - x_band:
        x_position -= 1
    elif x_medium > x_center + x_band:
        x_position += 1
    # Move Vertiacl Servo servo motor
    if y_medium < y_center - y_band:
        y_position -= 1
    elif y_medium > y_center + y_band:
        y_position += 1
    #print("x =", x_position , "y =", y_position)          
    if x_position >= 180:
        x_position = 180
    elif x_position <+ 0:
        x_position = 0
    else:
        x_position = x_position
    if y_position >= 180:
        y_position = 180
    elif y_position <= 0:
        y_position = 0
    else:
        y_position = y_position
    kit.servo[0].angle =(x_position) 
    kit.servo[1].angle =(y_position) 
#Exit Key        
    key = cv2.waitKey(1)
    if key == 27:
        kit.servo[0].angle =(90) 
        kit.servo[1].angle =(90) 
        print("key", key)    
        break
cv2.destroyAllWindows()
cap.release()
