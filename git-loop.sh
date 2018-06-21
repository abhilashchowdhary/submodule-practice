#!/bin/sh
for branch in $(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format='%(refname:short)')
do
	echo "$branch"
	git checkout "$branch"
	submodule_paths=('furry-octo-nemesis')
	for submodule_path in $submodule_paths
	do
		echo $submodule_path
		new_submodule_dir=$submodule_path"_dir"
		echo $new_submodule_dir
		mv "$submodule_path" "$new_submodule_dir"
		git submodule deinit -f -- $submodule_path
		rm -rf $new_submodule_dir"/.git"
		rm -f $new_submodule_dir"/.gitignore"
		git rm -rf "$submodule_path"
		git status
		#echo ".git/modules/"$submodule_path
		git add .
		git commit -m "moved submodule "$submodule_path" to directory"$new_submodule_dir
		git push origin "$branch"
	done
	COMMITS=($(git log --oneline | cut -d " " -f 1))
#	last_commit=${COMMITS[1]}
#	git checkout "$last_commit"
done
