<h1>Role-based Authorization</h1>


<pre style="font-size: 19px">

Objectives: 
    - Create user1 and user2
    - Assign admin role for user1 & read-only role for user2.
</pre>

<pre style="font-size: 19px">
 Prerequisites: 

       1- Ensure you have administrative access to Jenkins.
       2- Install the Role-Based Authorization Strategy plugin if it’s not already installed.
</pre>

# Steps to Create Role-Based Authorization:

```
Step 1: Install Role-Based Authorization Strategy Plugin

   1- Navigate to Manage Jenkins > Plugins.
   2- Under the Available tab, search for Role-Based Authorization Strategy.
   3- Install the plugin (restart Jenkins if required).
```
![](screenshots/jenkins%20Role%20Plugin.png)
```
Step 2: Enable Role-Based Authorization Strategy

   1- Go to Manage Jenkins > Security.
   2- Under Authorization, select Role-Based Strategy.
   3- Save the changes.
```
![](screenshots/Jenkins%20Auth.png)
```
Step 3: Create Roles

   1- Navigate to Manage Jenkins > Manage and Assign Roles > Manage Roles.
   2- Create the following roles:
            Admin Role:
               - Name: admin
               - Permissions: Grant all available permissions.
            Read-Only Role:
               - Name: read-only
               - Permissions: Grant only view-related permissions such as:
                   - Overall: Read
                   - Job: Read
                   - Credentials: View
```
![](screenshots/Manage%20Roles.png)
```
Step 4: Create Users

   1- Go to Manage Jenkins > Users.
   2- Create user1 and user2 with appropriate passwords.    
```
![](screenshots/Users.png)
```
Step 5: Assign Roles

   1- Navigate to Manage Jenkins > Manage and Assign Roles > Assign Roles.
   2- Assign the roles:
       - Assign the admin role to user1 under the Overall section.
       - Assign the read-only role to user2 under the Overall section.        
```
![](screenshots/Assign%20Roles.png)
```
Step 6: Verify Role Assignments

    1- Log in as user1 to confirm admin access.
    2- Log in as user2 to confirm read-only access.                 
```