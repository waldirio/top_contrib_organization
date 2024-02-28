#!/bin/bash

# 
# Developer .....: Waldirio M Pinheiro <waldirio@gmail.com>
# Date ..........: 02/26/2024
# Purpose .......: Check the organization and generate a CSV which will help to see the top contributors
# License .......: GPLv3
# 

ORG_URL=""
org_name=""

DIR="/tmp/top_contrib_report"
CSV_OUTPUT="/tmp/full_report.csv"
echo "org,project,pull_requests,author" > $CSV_OUTPUT

check_requirements()
{
  # Checking if git is around, once it's required
  which git &>/dev/null
  if [ $? -ne 0 ]; then
    echo "Please, install git on this machine. It's required to proceed"
    echo "exiting ..."
    exit
  fi

  # Cleaning any left over
  cleanup_dir
}

check_param()
{
  # Checking if the organization is present, if not, the script will stop
  if [ "$1" == "" ]; then
    echo "You need to pass the organization, for example:"
    echo
    echo "$0 https://github.com/theforeman/"
    echo
    echo "exiting ..."
    exit 1
  else
    ORG_URL=$1
  fi
}

cleanup_dir()
{
  # removing all the content from the temporary folder
  if [ -d $DIR ]; then
    echo "Stage directory around, cleaning stuff"
    rm -rf $DIR/*
  fi
}


check_org()
{
  # Checking if the organization is valid, if not, it will exit
  org_id=$(curl -s $ORG_URL | grep -o "organization:.*" | cut -d\" -f1 | cut -d: -f2)
  if [ "$org_id" == "" ]; then
    # echo "Not an organization ... moving on to the top 10"
    echo "Not an organization ... exiting now ..."
    exit 1
  else
    echo "Organization found ..., $org_id"
    org_name=$(echo $ORG_URL | cut -d"/" -f4)
  fi

  check_repos $org_name
}

check_repos()
{
  # Here we check all the available repos in the org
  org_name=$1
  echo "Org here - $org_name"
  stage=""
  stage1=""

  # Num of pages
  # curl -s -k https://github.com/orgs/theforeman/repositories | python3 -m json.tool | grep pageCount | awk '{print $2}' | sed 's/,//g'
  num_page=$(curl -s -k https://github.com/orgs/${org_name}/repositories | python3 -m json.tool | grep pageCount | awk '{print $2}' | sed 's/,//g')
  echo "Num of pages: $num_page"

  # Project names
  # curl -s -k https://github.com/orgs/theforeman/repositories\?page=2 | python3 -m json.tool | less
  for page_num in $(seq 1 $num_page)
  do
    # curl -s -k https://github.com/orgs/${org_name}/repositories\?page=$page_num | python3 -m json.tool
    repo_name=$(curl -s -k https://github.com/orgs/${org_name}/repositories\?page=$page_num | python3 -m json.tool | grep -E '(^                "name":)')
    stage=${stage}${repo_name}
  done

  
  # nice parse to grab only the repositories names
  # echo $stage | tr ',' '\n' | cut -d\" -f4 | grep -v ^$ | while read b

  # If you would like to limit some repos for troubleshooting purposes
  # echo $stage | tr ',' '\n' | cut -d\" -f4 | grep -v ^$ | head -n3 | while read b

  echo $stage | tr ',' '\n' | cut -d\" -f4 | grep -v ^$ | while read b
  do
    check_repo_info $b
  done

  echo
  echo "Please, check the file $CSV_OUTPUT"
}

check_repo_info()
{
  # And here is where the magic happen, cloning repo by repo, and collecting the information.
  # Also, updating the CSV file that will be used in the end of the day as a source file or dataset.
  repo_name=$1
  echo "check repo: $repo_name"

  # Cloning the repo to a temp folder
  # git clone https://github.com/theforeman/foreman.git /tmp/xpto 
  git clone $ORG_URL/${repo_name}.git $DIR/${repo_name}

  # Count the # of PRs
  # git log | grep ^Author | sort | uniq -c | sort -nr | head -n10
  cd $DIR/${repo_name}

  # git log | grep ^Author | sort | uniq -c | sort -nr | head -n10 | sed 's/ Author: /,/g' | sed 's/,/,"/' | sed 's/$/"/' | sed "s/^ */$repo_name,/g" | sed "s/^ */$org_name,/g" >> $CSV_OUTPUT
  git log | grep ^Author | sort | uniq -c | sort -nr | sed 's/ Author: /,/g' | sed 's/,/,"/' | sed 's/$/"/' | sed "s/^ */$repo_name,/g" | sed "s/^ */$org_name,/g" >> $CSV_OUTPUT
  # git log | grep ^Author | sort | uniq -c | sort -nr | sed 's/ Author: /,/g' | sed 's/,/,"/' | sed 's/$/"$/' | sed "s/^ */$repo_name,/g" | sed "s/^ */$org_name,/g" >> $CSV_OUTPUT
  cd

  # removing any repo info from local dir - $DIR
  cleanup_dir
}


## Main
check_requirements
check_param $1
check_org