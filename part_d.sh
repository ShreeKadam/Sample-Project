#!/bin/bash

set -x

REPO_DIR="ninja_repo"
BRANCH_NINJA="ninja"
README_PATH="$REPO_DIR/ninja/README.md"

create_repo() {
  mkdir "$REPO_DIR" && cd "$REPO_DIR" || exit
  git init
  echo "Initial commit" > initial.txt
  git add .
  git commit -m "Initial commit on master"
}

create_ninja_branch() {
  mkdir -p ninja
  echo "Trying fast forward merge" > ninja/README.md
  git checkout -b "$BRANCH_NINJA"
  git add ninja/README.md
  git commit -m "Add README.md in ninja folder with initial content"
}

merge_ninja_to_master_with_commit() {
  git checkout master
  git merge --no-ff "$BRANCH_NINJA" -m "Merge ninja branch with a merge commit"
}

modify_master_readme() {
  echo "Changes in master branch" > ninja/README.md
  git add ninja/README.md
  git commit -m "Modify README.md in master branch"
}

modify_ninja_readme() {
  git checkout "$BRANCH_NINJA"
  echo "Changes in ninja branch" > ninja/README.md
  git add ninja/README.md
  git commit -m "Modify README.md in ninja branch"
}

merge_with_conflict_and_resolve() {
  git checkout master
  git merge "$BRANCH_NINJA" || echo "Merge conflict detected!"
  git checkout --theirs ninja/README.md
  git add ninja/README.md
  git commit -m "Resolved conflict in favor of ninja branch (theirs)"
}

show_status() {
  git status
}


case "$1" in
  init)
    create_repo
    ;;
  create-ninja)
    create_ninja_branch
    ;;
  merge-no-ff)
    merge_ninja_to_master_with_commit
    ;;
  modify-master)
    modify_master_readme
    ;;
  modify-ninja)
    modify_ninja_readme
    ;;
  conflict-resolve)
    merge_with_conflict_and_resolve
    ;;
  status)
    show_status
    ;;
  all)
    create_repo
    create_ninja_branch
    merge_ninja_to_master_with_commit
    modify_master_readme
    modify_ninja_readme
    merge_with_conflict_and_resolve
    ;;
  *)
    echo "Usage: $0 {init|create-ninja|merge-no-ff|modify-master|modify-ninja|conflict-resolve|status|all}"
    ;;
esac

