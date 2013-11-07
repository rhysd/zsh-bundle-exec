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
                echo $d
                return
            fi
            d="$(dirname $d)"
        done
    }

    auto-bundle-exec-accept-line() {
        # TODO: expand alias using 'alias' command
        local command="$(echo $BUFFER | cut -d ' ' -f 1 )"

        if [ -n "$BUNDLE_EXEC_COMMANDS" ]; then
        fi

        # replace buffer with bundle exec path
        if [[ "$command" =~ '^[[:alnum:]_-]+$' ]]; then
            # return if not bundled
            local bundle_dir
            if [[ "$BUNDLE_EXEC_GEMFILE_CURRENT_DIR_ONLY" != '' ]]; then
                [ ! -f './Gemfile' ] && zle accept-line && return
                bundle_dir="$(pwd)"
            else
                bundle_dir="$(is-bundled)"
                [[ "$bundle_dir" == '' ]] && zle accept-line && return
            fi

            # get path through Ruby using bundler
            local bundler_driver="$(cat <<RUBY
begin
  require 'fileutils'
  require 'bundler/setup'
  cmd = "$command"
  if File.file?(cmd) && File.executable?(cmd)
    print cmd
    exit true
  elsif ENV['PATH']
    path = ENV['PATH'].split(File::PATH_SEPARATOR).find do |p|
      File.executable?(File.join(p, cmd))
    end
    executable = path && File.expand_path(cmd, path)
    print executable
    exit !!(executable && executable.start_with?("$bundle_dir"))
  end
rescue
  exit false
end
RUBY)"
            local be_cmd
            be_cmd="$(ruby -e $bundler_driver)"
            if [[ $? == 0 ]]; then
                # replace buffer
                # TODO do not use 'bundle exec'
                # replace command with $be_cmd
                BUFFER="bundle exec $BUFFER"
            fi

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

    # bind ^J if available
    if [[ "$(bindkey '^J' | cut -d ' ' -f 2)" == "accept-line" ]]; then
        bindkey '^J' auto_bundle_exec_accept_line
    fi

}
