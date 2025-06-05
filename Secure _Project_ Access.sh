#Project Directory Creation:

sudo mkdir /opt/secure_project: Creates the main project directory.
sudo chown root:root /opt/secure_project: Sets owner to root and group to root.
sudo chmod 750 /opt/secure_project: Gives root full access (rwx), root group read/execute (rx), and others no access. This is an initial restrictive step.


#File Creation:
echo "DB_PASSWORD=supersecret123" | sudo tee /opt/secure_project/config.conf: Creates a sensitive config file.
echo "Project documentation: Phase 1 complete." | sudo tee /opt/secure_project/docs.txt: Creates a general documentation file.
echo "Initial project log entry." | sudo tee /opt/secure_project/app.log: Creates a log file.

#Group Creation:
sudo groupadd project_admins: For administrators.
sudo groupadd project_developers: For developers.
sudo groupadd project_auditors: For auditors.

#User Creation and Assignment:
sudo useradd -m -g project_admins admin_user: Creates admin_user and makes project_admins their primary group.
sudo passwd admin_user: Sets password for admin_user.
sudo useradd -m -g project_developers developer_user: Creates developer_user and makes project_developers their primary group.
sudo passwd developer_user: Sets password for developer_user.
sudo useradd -m -g project_auditors auditor_user: Creates auditor_user and makes project_auditors their primary group.
sudo passwd auditor_user: Sets password for auditor_user.

#Applying Main Directory Permissions (Critical Step):
sudo chown -R root:project_admins /opt/secure_project: Recursively changes the owner to root and the group to project_admins for /opt/secure_project and all its contents. This means config.conf, docs.txt, and app.log are now owned by root:project_admins.
sudo chmod -R 770 /opt/secure_project: Recursively sets permissions for /opt/secure_project and all its contents. The owner (root) and group (project_admins) get full read, write, and execute permissions, while "others" get no permissions.

#Granular File Permissions (After recursive chmod -R 770):
sudo chmod 660 /opt/secure_project/config.conf:
Owner (root): Read, Write (6)
Group (project_admins): Read, Write (6)
Others: No permissions (0)
Outcome: root and project_admins can read/write.
sudo chown root:project_developers /opt/secure_project/docs.txt: Changes ownership to root:project_developers.
sudo chmod 664 /opt/secure_project/docs.txt:
Owner (root): Read, Write (6)
Group (project_developers): Read, Write (6)
Others: Read (4)
Outcome: root and project_developers can read/write. project_auditors (as others) can read.
sudo chown root:project_developers /opt/secure_project/app.log: Changes ownership to root:project_developers.
sudo chmod 664 /opt/secure_project/app.log:
Owner (root): Read, Write (6)
Group (project_developers): Read, Write (6)
Others: Read (4)
Outcome: root and project_developers can read/write. project_auditors (as others) can read.

#Test Results Simulation
Here's how the tests would play out, assuming you correct the directory and file paths to /opt/secure_project and /opt/secure_project/app.log:

Admin User (admin_user)
admin_user is a member of the project_admins group. The /opt/secure_project directory (and its contents) has root:project_admins ownership and 770 permissions. This means the project_admins group has full access to the directory and its contents.

ls -l /opt/secure_project: SUCCESS. admin_user is in project_admins and has execute permissions on the directory.
touch /opt/secure_project/new_admin_file.txt: SUCCESS. admin_user can create new files.
echo "Admin message" > /opt/secure_project/new_admin_file.txt: SUCCESS. admin_user can write to files.
cat /opt/secure_project/config.conf: SUCCESS. config.conf has 660 permissions with root:project_admins group, allowing admin_user to read it.
cat /opt/secure_project/app.log: SUCCESS. app.log has 664 permissions with root:project_developers group. admin_user (as root or part of the project_admins group with full access to the directory) can still read it.
rm /opt/secure_project/new_admin_file.txt: SUCCESS. admin_user has write permissions on the directory, allowing file deletion.
Summary for admin_user: All operations succeed as intended, confirming full administrative control.

Developer User (developer_user)
developer_user is a member of the project_developers group. They are not in project_admins.

ls -l /opt/secure_project: FAIL - Permission denied. As an "other" user, developer_user lacks the "execute" permission on the /opt/secure_project directory itself, preventing listing its contents or traversing into it.
cat /opt/secure_project/docs.txt: FAIL - Permission denied. For the same reason as ls -l.
cat /opt/secure_project/app.log: FAIL - Permission denied. For the same reason as ls -l.
echo "New developer log entry." >> /opt/secure_project/app.log: FAIL - Permission denied. For the same reason as ls -l.
cat /opt/secure_project/config.conf: FAIL - Permission denied. Even if they could access the directory, config.conf has 660 permissions with project_admins as group owner, and developer_user is not in that group.
touch /opt/secure_project/developer_scratch.txt: FAIL - Permission denied. developer_user lacks write permissions on the /opt/secure_project directory.
Summary for developer_user: All commands will fail because the main directory's permissions (770) prevent "others" (which includes developer_user) from even traversing into it.

Auditor User (auditor_user)
auditor_user is a member of the project_auditors group. They are not in project_admins or project_developers.

ls -l /opt/secure_project: FAIL - Permission denied. For the same reason as developer_user (lacks directory execute permission).
cat /opt/secure_project/docs.txt: FAIL - Permission denied. For the same reason.
cat /opt/secure_project/app.log: FAIL - Permission denied. For the same reason.
cat /opt/secure_project/config.conf: FAIL - Permission denied. Even if they could access the directory, config.conf has 660 permissions, and auditor_user is not in root or project_admins.
echo "Auditor attempt to write." >> /opt/secure_project/app.log: FAIL - Permission denied. For the same reason.
touch /opt/secure_project/auditor_note.txt: FAIL - Permission denied. auditor_user lacks write permissions on the /opt/secure_project directory.
Summary for auditor_user: All commands will fail due to the main directory's permissions preventing traversal.

Recommended Fix for Directory Permissions
To allow developer_user and auditor_user to access files within /opt/secure_project while maintaining the intended granular permissions, you need to grant "others" (meaning anyone not the owner or in the primary group for the directory) execute (x) permission on the directory. This allows them to traverse it.

You can achieve this by changing the permission of the main directory from 770 to 775:

Bash

sudo chmod 775 /opt/secure_project
Explanation of 775 on directory:

Owner (root): Read, Write, Execute (7)
Group (project_admins): Read, Write, Execute (7)
Others: Read, Execute (5) - The crucial x (execute) allows traversal, and r (read) allows listing contents (e.g., ls).
With this change, developer_user and auditor_user will be able to ls the directory and then interact with files based on the individual file permissions you set.

After applying sudo chmod 775 /opt/secure_project, the tests for developer_user and auditor_user would behave as follows (assuming path corrections):

Developer User (developer_user) with chmod 775 /opt/secure_project
ls -l /opt/secure_project: SUCCESS. They can traverse and list.
cat /opt/secure_project/docs.txt: SUCCESS. docs.txt has 664 and project_developers group ownership.
cat /opt/secure_project/app.log: SUCCESS. app.log has 664 and project_developers group ownership.
echo "New developer log entry." >> /opt/secure_project/app.log: SUCCESS. app.log has 664 and project_developers group ownership.
cat /opt/secure_project/config.conf: FAIL - Permission denied. config.conf has 660 and project_admins group ownership. developer_user is not in project_admins.
touch /opt/secure_project/developer_scratch.txt: FAIL - Permission denied. The directory itself only grants execute permissions to "others" (developers) not write permissions.
Auditor User (auditor_user) with chmod 775 /opt/secure_project
ls -l /opt/secure_project: SUCCESS. They can traverse and list.
cat /opt/secure_project/docs.txt: SUCCESS. docs.txt has 664 permissions, and auditor_user is an "other" user, allowing them to read.
cat /opt/secure_project/app.log: SUCCESS. app.log has 664 permissions, and auditor_user is an "other" user, allowing them to read.
cat /opt/secure_project/config.conf: FAIL - Permission denied. config.conf has 660 permissions, and auditor_user is not in root or project_admins.
echo "Auditor attempt to write." >> /opt/secure_project/app.log: FAIL - Permission denied. app.log has 664 permissions, which only grants read access to "others."
touch /opt/secure_project/auditor_note.txt: FAIL - Permission denied. The directory itself only grants execute permissions to "others" (auditors) not write permissions.

