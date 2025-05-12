#!/bin/bash

#set -x

usage() {
    echo "Usage:"
    echo "./gitBranch.sh -l"
    echo "./gitBranch.sh -b <branch_name>"
    echo "./gitBranch.sh -d <branch_name>"
    echo "./gitBranch.sh -m -1 <source_branch> -2 <target_branch>"
    echo "./gitBranch.sh -r -1 <source_branch> -2 <target_branch>"
}


check_git_repo() {
    git rev-parse --git-dir > /dev/null 2>&1 || {
        echo "Error: Not a git repository."
    }
}


list_branches() {
    echo "Listing branches:"
    git branch
}


create_branch() {
    local branch=$1
    echo "Creating branch: $branch"
    git branch "$branch"
}


delete_branch() {
    local branch=$1
    echo "Deleting branch: $branch"
    git branch -d "$branch"
}


merge_branches() {
    local branch1=$1
    local branch2=$2
    echo "Merging $branch1 into $branch2"
    git checkout "$branch2" && git merge "$branch1"
}


rebase_branches() {
    local branch1=$1
    local branch2=$2
    echo "Rebasing $branch1 onto $branch2"
    git checkout "$branch1" && git rebase "$branch2"
}


check_git_repo

action=""
branch=""
branch1=""
brranch2=""

while [[ $# -gt 0 ]]; 
do
    case $1 in
        -l) action="list" ;;
        -b) action="create"
            branch="$2"
            shift ;;
        -d)
            action="delete"
            branch="$2"
            shift
            ;;
        -m)
            action="merge"
            ;;
        -r)
            action="rebase"
            ;;
        -1)
            branch1="$2"
            shift
            ;;
        -2)
            branch2="$2"
            shift
            ;;
        *)
            usage
            ;;
    esac
    shift
done


case "$action" in
    list)
        list_branches
        ;;
    create)
        [ -z "$branch" ] && usage
        create_branch "$branch"
        ;;
    delete)
        [ -z "$branch" ] && usage
        delete_branch "$branch"
        ;;
    merge)
        [ -z "$branch1" ] || [ -z "$branch2" ] && usage
        merge_branches "$branch1" "$branch2"
        ;;
    rebase)
        [ -z "$branch1" ] || [ -z "$branch2" ] && usage
        rebase_branches "$branch1" "$branch2"
        ;;
    *)
        usage
        ;;
esac

