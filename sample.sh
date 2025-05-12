#!/bin/bash

while getopts ":u:d:" opt; do
  case $opt in
    u) repo_url=$OPTARG ;;
    d) days=$OPTARG ;;
  esac
done

# Clone the repo to a temp folder
tmpdir=$(mktemp -d)
cd "$tmpdir" || exit
git clone "$repo_url" repo
cd repo || exit

# Generate report
echo "Date,Author,Email,Message,Files,Valid" > commit_report.csv
git log --since="$days days ago" --pretty=format:'%ad|%an|%ae|%s|%H' --date=short |
while IFS='|' read -r date author email msg hash; do
  files=$(git show --pretty="" --name-only "$hash" | paste -s -d "," -)
  [[ $msg =~ ^JIRA-[0-9]+: ]] && valid=YES || valid=NO
  echo "$date,$author,$email,\"$msg\",\"$files\",$valid" >> ../commit_report.csv
done

mv ../commit_report.csv .
echo "Commit report saved to commit_report.csv"
