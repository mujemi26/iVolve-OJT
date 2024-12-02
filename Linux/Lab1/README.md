Objective: Create a new group named ivolve and a new user assigned to this group with a secure password. Configure the user’s permissions to allow installing Nginx with elevated privileges using the sudo tool

First Step we need to create a user
![nginx user](screenshots/1.jpg)
Then create a new group called iVolve
![ivolve Group](screenshots/2.jpg)
After that we must add the new user to Sudeors file so that the user can instatll nginx without password
![adding user to sudoers](screenshots/3.jpg)
!!! IT Works !!!
![installing nginx](screenshots/4.jpg)
When the user try to install anything else it needs password
![a password required](screenshots/5.jpg)
