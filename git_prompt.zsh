autoload -Uz vcs_info

git_remote_name() {
    git remote get-url origin 2>/dev/null | sed -E 's#(git@|https://)[^:/]+[:/]([^/]+/[^.]+).*#\2#'
}

precmd() {
    vcs_info
    local remote="$(git_remote_name)"
    local branch="${vcs_info_msg_0_#*:}"
    local git_info=""

    branch1="${branch%%|*}"
    state="${branch#*|}"

    # Check if we're inside a git repository
    if [[ -n $vcs_info_msg_0_ ]]; then
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

