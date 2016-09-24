# asana_to_jira


A simple ruby script to move tasks from asana to jira.

Steps:

1. Install ruby.
2. Clone/Download repo.
3. Run `ruby app.rb`

```bash
ruby app.rb
Enter Personal Access Token for Asana :
0/b42absjdf0f0415094dc5ffac4ab7
Authentication in progress...
You have logged in to Asana as Dinesh Sawant(dinesh@mail.com)
Fetching All Users, Workspaces...
Found 3 users.
List of workspaces
W (number) Workspace Name [workspace_id]
W (1) totech [4006520037031]
W (2) Adey [4172978670176]
W (3) Personal Projects [49346170860]
Enter workspace number :
1
You selected : totech
Fetching Projects for totech
P (number) Project Name [project_id]
P (1) S Project [40016521053108]
P (2) test [85676176646814]
P (3) CM [90230699491911]
Enter Project number :
2
Fetching Tasks for totech/test
2 tasks found.
T (number) Task Name @assignee [task_id]
T (1) test2 @[] [8567617664689]
T (2) test1 @[Dinesh Sawant] [8567617664685]
You have chosen to create all above tasks on JIRA.
Enter JIRA URL with http/https eg. https://team.atlassian.net
https://dbteam.atlassian.net
Enter your JIRA username:
dineshs@db.com
Enter your JIRA password:
thepassword
Authentication in progress...
You have logged in to Jira as dinesh(dinesha@mail.com)
Fetching All Projects...
P (number) Project Name [project_id]
P (1) Alto ["10300"]
P (2) Project A ["10100"]
P (3) Meta ["10201"]
P (4) Fit ["10102"]
P (5) Omega Tasks
Enter Project number :
3
Copy all tasks from
          ASANA[totech
          [test]]
          to JIRA [db] ? (yes/no)

         yes

         Fetching Issue Create Meta...
         I (number) Issue Name [issue_id]
I (1) Task ["10002"]
I (2) Sub-task ["10003"]
I (3) New Feature ["10100"]
I (4) Improvement ["10101"]
I (5) Bug ["10004"]
I (6) Story ["10001"]
I (7) Epic ["10000"]
Enter Issue Type Number
1
You have selected Task
Proceed to create issues on Jira?(yes/no)
yes
{"issues"=>[{"id"=>"12400", "key"=>"db-1672", "self"=>"https://dbteam.atlassian.net/rest/api/2/issue/12400"}, {"id"=>"12401", "key"=>"db-1673", "self"=>"https://dbteam.atlassian.net/rest/api/2/issue/12401"}], "errors"=>[]}
```
