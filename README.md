# Auto Shutdown ESXi

## What is that ?

This script allow to shutdown an ESXi plugged on an UPS inverter.

## How it is working ?

There is 3 set of IP.
- The first, is some IP of devices that need to respond when only the UPS is on. For exemple a switch, a raspberry pi, a other server.
- The second, is devices IP not plugged on the UPS. In case of power cut, these devices are not responding
- The third, is some public IP like Google, Cloudflare, ... if the server can reach internet, the power is good :) (depending of your infrastructure)

A test is made for each set. If more than the half answer to one ping so the test is good.
More IP you give, more less false positive.
For example, if you have only one IP on the second set, and if this IP fail due to some misconfiuration ... the script will shuting down the current server.
This script must be tested by mocking the shutdown function for exemple and checking the result.
Do the test for real in order to see if it is working :)

For any issue -> open it
For any quastion -> https://twitter.com/__gianninou__


