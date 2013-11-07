# check if bundle command exists
! which "bundle" > /dev/null && return

# anonymous function for namespace
function() {

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

    get-bundle-dir() {
        if [[ "$BUNDLE_EXEC_GEMFILE_CURRENT_DIR_ONLY" != '' ]]; then
            [ ! -f './Gemfile' ] && return
            echo "$(pwd)"
        else
            echo "$(is-bundled)"
        fi
    }

    is-exceptional(){
        if [ -n "$BUNDLE_EXEC_COMMANDS" ]; then
            # TODO
            return 0
        fi

        return 1
    }

    auto-bundle-exec-accept-line() {
        # trim and split into command and arguments
        local trimmed="$(echo $BUFFER | tr -d ' ')"
        local command="${${trimmed}%% *}"
        local args="${${trimmed}#$command}"

        # unalias if alias is used
        local unaliased="${${${${$(alias $command)#*=}}#\'}%\'}"
        if [[ "$unaliased" != '' ]]; then
            command="${unaliased% *}"
            local unaliased_args="${unaliased#$command}"
            if [[ "$unaliased_args" != '' ]]; then
                args="$unaliased_args $args"
            fi
        fi

        # check command
        if $(is-exceptional "$command") || [[ ! "$command" =~ '^[[:alnum:]_-]+$' ]]; then
            zle accept-line && return
        fi

        # return if not bundled
        local bundle_dir="$(get-bundle-dir)"
        [[ $bundle_dir == '' ]] && zle accept-line && return

        # get path through Ruby using bundler
        local bundler_driver="$(cat <<-RUBY
			begin
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
        if (( $? == 0 )); then
            if [[ "$BUNDLE_EXEC_EXPAND_ALIASE" == '' ]]; then
                BUFFER="bundle exec $command$args"
            else
                BUFFER="$be_cmd$args"
            fi
        fi

        zle accept-line
    }

    zle -N auto_bundle_exec_accept_line auto-bundle-exec-accept-line

    # if ^M key is not bound
    if [[ "$(bindkey '^M' | cut -d ' ' -f 2)" == "accept-line" ]]; then
        bindkey '^M' auto_bundle_exec_accept_line
    fi

    # bind ^J if available
    if [[ "$(bindkey '^J' | cut -d ' ' -f 2)" == "accept-line" ]]; then
        bindkey '^J' auto_bundle_exec_accept_line
    fi

}
