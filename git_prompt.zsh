autoload -Uz vcs_info

git_remote_name() {
    git remote get-url origin 2>/dev/null | sed -E 's#(git@|https://)[^:/]+[:/]([^/]+/[^.]+).*#\2#'
}

count_git_status() {

    	
    # Get the status of files and count added, modified, and deleted files
    local added=$(git status -s | grep -c '^A')
    local modified=$(git status -s | grep -c '^M')
    local deleted=$(git status -s | grep -c '^D')

    # Print the results in the desired format
    echo "A:$added-M:$modified-D:$deleted"
}


precmd() {
    vcs_info
    local remote="$(git_remote_name)"
    local branch="${vcs_info_msg_0_#*:}"
    local git_info=""

    # Check if we're inside a git repository
    if [[ -n $vcs_info_msg_0_ ]]; then
        
	branch1="${branch%%|*}"
	#state="${branch#*|}"
	state="$(count_git_status)"

	if [[ "$branch1" == "$state" ]]; then
	   state="ok"
	fi

        if [[ -n $remote && -n $branch ]]; then
            git_info="${remote}/${branch1}"
        fi

        # Extract the status (rebasing, merging, etc.) without any extra info
        local git_status=""
        if [[ -n $vcs_info_msg_0_ ]]; then
            # Extract the status information after the colon (e.g., "rebasing", "merging")
            git_status=$(echo "$vcs_info_msg_0_" | sed 's/^[^:]*://')
            [[ -n $git_status ]] && git_status="*$git_status*"
        fi

        # Final prompt: displaying the desired information with Git info
        PROMPT='%F{green}%n%f@%F{blue}%~%f~%F{yellow}'"$git_info"'%f %F{magenta}'"$state"%f' >'
    else
        # Set the prompt when not in a Git repository
        PROMPT='%F{green}%n%f@%F{blue}%~%f > '
    fi
}

zstyle ':vcs_info:git:*' formats '%b'
zstyle ':vcs_info:git:*' actionformats '%b|%a'

