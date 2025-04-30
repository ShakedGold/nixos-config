aws_prompt_info() {
  if [ -n "$AWS_PROFILE" ]; then
    local ax_aws_profile_color
    if [ "$AWS_PROFILE" = "development" ]; then
      ax_aws_profile_color=blue
    else
      ax_aws_profile_color=green
    fi
    echo "$fg[red][%{$fg_bold[white]%}aws:%{$fg[$ax_aws_profile_color]%}$AWS_PROFILE%{$fg_bold[white]%}%{$reset_color%}$fg[red]] "
  fi
}

get_git_aws_prompt2() {
  if  git rev-parse --is-inside-work-tree &> /dev/null || [ -n "$AWS_PROFILE" ]; then
    echo -n "$(aws_prompt_info)%}%(?,,%{$fg[red]%}[%{$fg_bold[white]%}%?%{$reset_color%}%{$fg[red]%}])
%{$fg[red]%}└"
  fi
}
get_git_aws_prompt1() {
  if  git rev-parse --is-inside-work-tree &> /dev/null || [ -n "$AWS_PROFILE" ]; then
    echo -n "%{$fg[red]%}┌"
  fi
}
PROMPT=$'$(get_git_aws_prompt1)$(git_prompt_info)$(get_git_aws_prompt2)%{$fg[red]%}[%{$fg_bold[white]%}%~%{$reset_color%}%{$fg[red]%}]>%{$reset_color%} '
PS2=$' %{$fg[red]%}|>%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[red]%}[%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$fg[red]%}] "
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}⚡%{$reset_color%}"
