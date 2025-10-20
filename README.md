EdgeTX dashboard specifically for Rotorflight 

They are designed around a RadioMaster TX16 colour screen with resolution of 480x272

There are two dashboard, a Nitro specific and Electric specific each with their own configuration options.

These are telemetry-only dashboard that requires the Official Rotorflight lua scripts be installed and the rf2bg script configured as a background task

Credit: The dashboards are based on the work originally developed by Shmuely and his RF2_toush suite.

How to use:
- Download and install the rf2 official widget
- Enable the background task
- Download this widget and extract into the SCRIPTS and WIDGETS folders
- Add a new screen. Configure the screen as fullscreen and turn off Topbar, Flight Mode, Sliders and trims
- Add the RF2_dashN (Nitro) or RF2_dashE (Electric) widgets to the screen


Electric Dashboard

<img width="486" height="285" alt="image" src="https://github.com/user-attachments/assets/f4f0c94c-2aae-4c4a-864f-ace546d7822f" />

Options:

<img width="487" height="282" alt="image" src="https://github.com/user-attachments/assets/744d1026-85c5-44d1-a6c1-a27326363f29" />
<img width="486" height="283" alt="image" src="https://github.com/user-attachments/assets/a64b5740-351c-4fda-9c5c-a3d136a57c2f" />


Nitro Dashboard

<img width="486" height="287" alt="image" src="https://github.com/user-attachments/assets/6d32897d-7cf8-4d52-9bf1-e029c19ff685" />

Options:

<img width="487" height="277" alt="image" src="https://github.com/user-attachments/assets/15ab3139-d554-4f9a-adea-e4a8b53a64d4" />

The following Telemetry options need to be enabled for the Dashboards to work properly:
- Battery
  - Battery Voltage
  - Battery Current
  - Battery Consumption
- Voltage
  - ESC Voltage
  - BEC Voltage
- Temperature
  - ESC Temperature
- RPM
  - Headspeed
  - Tailspeed
- Status
  - Model Id
  - Flight Model
  - Arming Flags
  - Arming Disable Flags
  - Governor State
- Profile
  - PID Profile
  - Rates Profile
- Control
  - Control (hi-res)
  - Throttle Control
- System
  - Heartbeat

