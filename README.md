Hue AIR
=======
Access the Philips Hue Bridge through AS3/AIR. The full API (1.0) has been implemented, so you can control lights, groups and schedules through the HueConnector class. The project consists of three parts:

Connector
---------
If you all want to do is simply access the Hue Bridge, you can find everything you need here. The full official API has been implemented.

Manager
-------
A basic wrapper around the connector, that allows you to use fully typed ActionScript representations of the lights and groups, instead of communicating with the Bridge directly. Simply change properties on the HueLight and HueGroup instances and the manager will handle communication back to the Bridge. 

You can even use your favorite tween engine to tween light properties. The manager includes rate limiting, so the Bridge does not get overloaded. Keep in mind that data throughput is severely limited (especialy for groups). Even though the manager includes methods to smooth out transitions, do not expect to tween more than 3 lights very smoothly.

Example application
-------------------
A simple AIR application, that serves mainly as an example of how the library works. It includes:
* Bridge discovery
* Bridge registration
* Controlling groups
* Controlling lights
* Adding schedules



You can find source code for the required iMotion library here: https://github.com/dyvoid/imotion-library
