autoload -Uz vcs_info

git_remote_name() {
    git remote get-url origin 2>/dev/null | sed -E 's#(git@|https://)[^:/]+[:/]([^/]+/[^.]+).*#\2#'
}

# Function to count added, modified, and deleted files using vcs_info
count_git_status() {
    # Get the status of files and count added, modified, and deleted files
    local added=$(git status -s | grep -c '^A ')
    local modified=$(git status -s | grep -c '^ M')  # Added space after M to correctly match
    local deleted=$(git status -s | grep -c '^ D')

    # Return the results in the desired format
    echo "A:$added-M:$modified-D:$deleted"
}

check_git_sync_status() {
    # Check the sync status (ahead/behind/diverged) from vcs_info
    local sync_status
    sync_status=$(git status -sb | grep -oE "ahead|behind|diverged")

    if [[ "$sync_status" == "ahead" ]]; then
        echo "ahead"
    elif [[ "$sync_status" == "behind" ]]; then
        echo "behind"
    elif [[ "$sync_status" == "diverged" ]]; then
        echo "diverged"
    else
        echo "sync"
    fi
}

precmd() {
    vcs_info
    local remote="$(git_remote_name)"
    local branch="${vcs_info_msg_0_#*:}"
    local git_info=""

    # Check if we're inside a git repository
    if [[ -n $vcs_info_msg_0_ ]]; then
        branch1="${branch%%|*}"
        local git_state
        git_state="$(count_git_status)"
        local sync_status
        sync_status="$(check_git_sync_status)"

        if [[ -n $remote && -n $branch ]]; then
            git_info="${remote}/${branch1}"
        fi

        # Final prompt: displaying the desired information with Git info
        PROMPT='%F{160}git%f@%F{blue}%~%f~%F{yellow}'"$git_info"'%f %F{magenta}'"$git_state"'%f %F{47}'"$sync_status"'%f > '
    else
        # Set the prompt when not in a Git repository
        PROMPT='%F{yellow}%n%f@%F{blue}%~%f > '
    fi
}

# Configure vcs_info for Git
zstyle ':vcs_info:git:*' formats '%b'
zstyle ':vcs_info:git:*' actionformats '%b|%a'
