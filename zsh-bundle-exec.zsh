# anonymous function for namespace
function() {

    zmodload zsh/parameter
    local this_file="${funcsourcetrace[1]%:*}"

    autoload -U is-at-least
    if is-at-least 4.3.10; then
        export ZSH_BUNDLE_EXEC_DIR="${this_file:A:h}"
    else
        export ZSH_BUNDLE_EXEC_DIR="${this_file:h}"
    fi

    is-bundled() {
        local d="$(pwd)"
        while [[ "$(dirname $d)" != "/" ]]; do
            if [ -f "$d/Gemfile" ]; then
                return
            fi
            d="$(dirname $d)"
        done
        false
    }

    auto-bundle-exec-accept-line() {
        local command="$(echo $BUFFER | cut -d ' ' -f 1 )"

        if [ -n "$BUNDLE_EXEC_COMMANDS" ]; then
        fi

        if [[ "$command" =~ '^[[:alnum:]_-]+$' ]] && [[ "$BUNDLE_EXEC_GEMFILE_CURRENT_DIR_ONLY" == '' ]] && is-bundled || [ -f "./Gemfile" ]; then
            local be_cmd
            be_cmd="$(ruby -rbundler -rbundler/setup -e "print(result = Bundler.which(\"$command\")); exit(!!result)")"
            if [[ $? != 0 ]]; then
                zle accept-line
                return
            fi
            BUFFER="bundle exec $BUFFER"
        fi
        zle accept-line
    }

    zle -N auto_bundle_exec_accept_line auto-bundle-exec-accept-line

    # if ^M key is not bound
    if [[ "$(bindkey '^M' | cut -d ' ' -f 2)" == "accept-line" ]]; then
        bindkey '^M' auto_bundle_exec_accept_line
    else
        echo "zsh-bundle-exec: ^M is already bound" 1>&2
    fi

}
