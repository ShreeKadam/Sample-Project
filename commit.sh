#!/bin/bash

#set -x

usage() {
    echo "Usage: $0 -u <repo_url> -d <days> [-f csv|html]"
}


is_valid_commit() {
    [[ "$1" =~ ^JIRA-[0-9]+:\  ]] && echo "Yes" || echo "No"
}


generate_csv() {
    echo "Commit ID,Author,Email,Message,Files Changed,Valid Commit" > /home/witcher/gitt/Sample-Project/commit_report.csv
    for commit in $commits; 
    do
        details=$(git show --quiet --format="%H|%an|%ae|%s" "$commit")
        commit_id=$(echo "$details" | cut -d'|' -f1)
        author=$(echo "$details" | cut -d'|' -f2)
        email=$(echo "$details" | cut -d'|' -f3)
        message=$(echo "$details" | cut -d'|' -f4)
        files=$(git show --name-only --pretty="" "$commit" | paste -sd "," -)
        valid=$(is_valid_commit "$message")
        echo "\"$commit_id\",\"$author\",\"$email\",\"$message\",\"$files\",\"$valid\"" >> /home/witcher/gitt/Sample-Project/commit_report.csv
    done
    echo "CSV report generated: commit_report.csv"
}

generate_html() {
    echo "<html><head><title>Commit Report</title></head><body><table border='1'>" > /home/witcher/gitt/Sample-Project/commit_report.html
    echo "<tr><th>Commit ID</th><th>Author</th><th>Email</th><th>Message</th><th>Files Changed</th><th>Valid Commit</th></tr>" >> /home/witcher/gitt/Sample-Project/commit_report.html
    for commit in $commits; 
    do
        details=$(git show --quiet --format="%H|%an|%ae|%s" "$commit")
        commit_id=$(echo "$details" | cut -d'|' -f1)
        author=$(echo "$details" | cut -d'|' -f2)
        email=$(echo "$details" | cut -d'|' -f3)
        message=$(echo "$details" | cut -d'|' -f4)
        files=$(git show --name-only --pretty="" "$commit" | paste -sd ", " -)
        valid=$(is_valid_commit "$message")
        echo "<tr><td>$commit_id</td><td>$author</td><td>$email</td><td>$message</td><td>$files</td><td>$valid</td></tr>" >> /home/witcher/gitt/Sample-Project/commit_report.html
    done
    echo "</table></body></html>" >> /home/witcher/gitt/Sample-Project/commit_report.html
    echo "HTML report generated: commit_report.html"
}


while getopts "u:d:f:" opt; 
do
    case $opt in
        u) repo_url="$OPTARG" ;;
        d) days="$OPTARG" ;;
        f) format="$OPTARG" ;;
        *) usage ;;
    esac
done


if [[ -z "$repo_url" || -z "$days" ]]; 
then
    usage
fi


format="${format:-csv}"


tmp_dir=$(mktemp -d)
git clone --quiet "$repo_url" "$tmp_dir" || { echo "Failed to clone repo"; }
cd "$tmp_dir"


commits=$(git log --since="$days days ago" --format="%H")


case "$format" in
    csv) generate_csv ;;
    html) generate_html ;;
    *) echo "Invalid format. Use csv or html." ;;
esac

cd - > /dev/null
rm -rf "$tmp_dir"

REPORT_DIR="/home/witcher/gitt/Sample-Project/reports"
mkdir -p "$REPORT_DIR"
echo "Commit ID,Author,Email,Message,Files Changed,Valid Commit" > "$REPORT_DIR/commit_report.csv"

