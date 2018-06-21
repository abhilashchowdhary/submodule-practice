#!/bin/sh

function remove_submodule() {
submodule_path=$1
git submodule deinit -f -- $submodule_path
rm -rf ".git/modules/"$submodule_path
git rm -rf "$submodule_path"
git status
return 0
}


function move_submodule_into_normal_dir() {
top_level_branch=$1
submodule_path=$2

# check if the submodule_path actually refers to a git repo
test -e $submodule_path"/.git"
if [ $? -gt 0 ]
then
	echo $submodule_path" not a git repo. Exiting"
	return 1 #function returns a non-zero exit code
fi

echo "Going to move submodule "$submodule_path" in branch "$top_level_branch
new_submodule_dir=$submodule_path"_dir"
echo $new_submodule_dir
mv "$submodule_path" "$new_submodule_dir"
rm -rf $new_submodule_dir"/.git"
rm -f $new_submodule_dir"/.gitignore"

remove_submodule $submodule_path
ret_val=$?

if [ $ret_val -gt 0 ]
then
	        return 1 #submodule wasn't removed properly. returning with non-zero exit code
fi

echo "Submodule "$submodule_path" was removed successfully. Pushing the changes to the repo"

git add .
git commit -m "moved submodule "$submodule_path" to directory"$new_submodule_dir
git push origin "$branch"

# the function returned with exit code 0
return 0
}

for branch in $(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)')
do
	echo "$branch"
	git checkout "$branch"
	#submodule_paths=('furry-octo-nemesis')
	submodule_paths=('scaling-octo-wallhack')
	for submodule_path in $submodule_paths
	do
		move_submodule_into_normal_dir "$branch" "$submodule_path"
		ret_val=$?
		if [ $ret_val -gt 0 ]
		then
			echo "Exiting as submodule "$submodule_path" returned non-zero exit-code of "$ret_val
			exit
		fi
	done
	COMMITS=($(git log --oneline | cut -d " " -f 1))
#	last_commit=${COMMITS[1]}
#	git checkout "$last_commit"
done
