# top_contrib_organization
The goal of this script is to collect a set of information from a github organization, information that will help us track all the repos, and contributors for each repo (people who pushed a pull request and the same was merged into the code)

Here we can see an example
```
./top_contrib_org.sh 
Stage directory around, cleaning stuff
You need to pass the organization, for example:

./top_contrib_org.sh https://github.com/theforeman/

exiting ...
```

You need to pass the organization. If you pass something that is not valid, the script will stop
```
./top_contrib_org.sh https://sss
Stage directory around, cleaning stuff
Not an organization ... exiting now ...
```

When passing a valid org, we can see something like below
```
./top_contrib_org.sh https://github.com/theforeman/
Stage directory around, cleaning stuff
Organization found ..., 1439844
Org here - theforeman
Num of pages: 8
check repo: foreman
Cloning into '/tmp/top_contrib_report/foreman'...
remote: Enumerating objects: 163119, done.
remote: Counting objects: 100% (1461/1461), done.
...

Please, check the file /tmp/full_report.csv
```

At the end of the process, you can play with the file `/tmp/full_report.csv` which will contains all the output in `CSV` format.

Here, you can have an idea about the file content
```
head -n5 /tmp/full_report.csv
org,project,pull_requests,author
theforeman,foreman,1519,"Ohad Levy <ohadlevy@gmail.com>"
theforeman,foreman,525,"Tomer Brisker <tbrisker@gmail.com>"
theforeman,foreman,409,"Marek Hulan <mhulan@redhat.com>"
theforeman,foreman,389,"Dominic Cleal <dcleal@redhat.com>"
```

Enjoy the project and let me know if you have questions, concerns or issues.

Waldirio