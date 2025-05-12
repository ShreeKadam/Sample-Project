#!/bin/bash

#set -x

print_usage() {
    echo "Usage:"
    echo "  $0 -t <tag_name> "
    echo "  $0 -l            "
    echo "  $0 -d <tag_name> "
}

create_tag() {
    local tag_name="$1"
    if git rev-parse "$tag_name" >/dev/null 2>&1; 
    then
        echo "Tag '$tag_name' already exists."
    else
        git tag "$tag_name"
        echo "Tag '$tag_name' created."
    fi
}

list_tags() {
    echo "Existing tags:"
    git tag
}

delete_tag() {
    local tag_name="$1"
    if git rev-parse "$tag_name" >/dev/null 2>&1; 
    then
        git tag -d "$tag_name"
        echo "Tag '$tag_name' deleted."
    else
        echo "Tag '$tag_name' does not exist."
    fi
}

if [ $# -eq 0 ]; 
then
    print_usage
fi

while getopts ":t:l:d:" opt; 
do
    case "$opt" in
        t)
            create_tag "$OPTARG"
            ;;
        l)
            list_tags
            ;;
        d)
            delete_tag "$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            print_usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            print_usage
            ;;
    esac
done

