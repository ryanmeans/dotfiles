# Profile
# zmodload zsh/zprof

# vim mode
bindkey -v


### PROMPT SETUP
# Looks good for PaperColor-light, at least
# Probably gets overwriten immediatly by my_set_prompt()
PS1='%F{green}%n:%F{blue}%2~ %f$ '

source ~/Repos/gitstatus/gitstatus.plugin.zsh

function my_set_prompt() {
  PS1='%F{10}%n:%F{12}%2~'
  if gitstatus_query MY && [[ $VCS_STATUS_RESULT == ok-sync ]]; then
    PS1+=" %F{9}<"
    PS1+=${${VCS_STATUS_LOCAL_BRANCH:-${VCS_STATUS_TAG:-@${VCS_STATUS_COMMIT}}}//\%/%%}
    (( VCS_STATUS_NUM_UNSTAGED  )) && PS1+="*"
    # (( VCS_STATUS_NUM_UNTRACKED )) && PS1+="?"
    PS1+=">"
  fi
  PS1+='%f$ '

  if [ ! -z "${VIRTUAL_ENV}" ]; then
    PS1="(`basename $VIRTUAL_ENV`) $PS1"
  fi
}

gitstatus_stop 'MY' && gitstatus_start -s 0 -u 1 -c 0 -d 0 'MY'
autoload -Uz add-zsh-hook
add-zsh-hook precmd my_set_prompt

setopt inc_append_history

export HISTSIZE=100000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY


### PYENV
function lpyenv() {
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}

### NVM
# This shit is too slow holy hell
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

### KUBECTL
autoload -Uz compinit
compinit
source <(kubectl completion zsh)



### FZF
export FZF_DEFAULT_COMMAND="rg --files --hidden -g '!.git'"

_fzf_compgen_path() {
  local dir=$(git rev-parse --show-toplevel 2> /dev/null)
  if [[ $? -eq 0 ]]; then
    rg --files --no-ignore-vcs --hidden -g '!.git' $dir
  else
    rg --files --no-ignore-vcs --hidden -g '!.git' $1
  fi
}

_fzf_compgen_dir() {
  local dir=$(git rev-parse --show-toplevel 2> /dev/null)
  if [[ $? -eq 0 ]]; then
    fd -a --base-directory=$dir --color=never --type=d .
  else
    fd -a --color=never --type=d . $1
  fi
}



[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export PATH="$(brew --prefix)/opt/python@3.10/libexec/bin:$PATH"



### PATHS
# Add homebrew installed include and libs to default search path
export CPATH=$CPATH:/opt/homebrew/include
export LIBRARY_PATH=$LIBRARY_PATH:/opt/homebrew/lib
export PATH="$HOME/.local/bin:$PATH"

### ALIASES
alias vim='nvim'
alias ls="gls --color -h --group-directories-first -C"
alias ll="gls --color -lh --group-directories-first"
alias tunnel="tmux new-window -ntunnel 'minikube tunnel'"

alias pcluster="~/pangea/dev/tools/switch_to_cluster.py"
alias pbastion="~/pangea/dev/tools/open_bastion.py"

alias k='kubectl'
alias kn='kubectl -n $KUBECTL_NAMESPACE'
export EDITOR='nvim'

alias gm="git checkout main && git pull"
alias grm="git checkout main && git pull && git checkout - && git rebase main"

pexport() {
  export "$1"=$(~/pangea/dev/tools/determine_gitlab_variable_value.py "$1")
}

retag_privc() {
	git push --delete origin PrivC
	git tag -d PrivC
	git tag PrivC
	git push origin PrivC
}

REPO_ROOT=$(realpath ~/pangea)
#
# poetry() {
#   if [[ $1 == "init" ]]; then
#     command "${@:0}"
#   fi
#   if [[ $PWD/ != $REPO_ROOT/* ]] || [ -f pyproject.toml ]; then
#     command poetry "$@"
#     return $?
#   fi
#   local cmd=$1
#   shift
# 	command poetry $cmd "$@"
#   return $?
# }
#
# ppoetry() {
# 	command poetry --directory="${REPO_ROOT}" "$@"
# }
#
# python() {
#   if [[ $PWD/ != $REPO_ROOT/* ]]; then
#     command python "$@"
#   else
#     poetry run python "$@"
#   fi
#   return $?
# }
#
# ppython() {
# 	ppoetry run python "$@"
# }

### SOURCES
source ~/.gitlab_env
source ~/.cloud_env
source ~/.jira_env
source ~/.lua_rocks
source ~/.llm_env
source "/Users/means/pangea/dev/aliases/kubernetes.sh"
source $HOME/.cargo/env

export GOOGLE_CREDENTIALS=/Users/means/.gcloud/credential-bootstrap.json
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION="python"
path=("/opt/homebrew/opt/sqlite3/bin" $path)
path=("/opt/homebrew/opt/libpq/bin" $path)
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/opt/homebrew/include
typeset -U PATH path

# export GOPROXY="https://builder.scranton.dev.pangea.cloud/artifactory/api/go/golang"

# Stop profiling
# zprof

. "$HOME/.cargo/env"
