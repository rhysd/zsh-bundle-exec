Never Type in `bundle exec`
========================

This is a Zsh plugin to insert `bundle exec` automatically.  It detects Gemfile, expand an alias, check the command and insert `bundle exec` nicely.

![screenshot](http://gifzo.net/BAUT7u7dr0U.gif)


## How to Install and Setup

Clone this repository and write below line to your `zshenv`.

```
source path/to/zsh-bundle-exec.zsh
```

This plugin attempt to overwrite `^M` and `^J` binding.  If you already use `^M` or `^J` for other binding, this plugin doesn't overwrite it.  In the case, you should call zbe-bundle-exec-accept-line in the binding.


## Customization

You can customize behavior of this plugin with environment variables.

### `$BUNDLE_EXEC_GEMFILE_CURRENT_DIR_ONLY`

If `$BUNDLE_EXEC_GEMFILE_CURRENT_DIR_ONLY` is not empty, `bundle exec` is inserted automatically if and only if `Gemfile` exists in the current directory.

```sh
export BUNDLE_EXEC_GEMFILE_CURRENT_DIR_ONLY=yes
```

### `$BUNDLE_EXEC_COMMANDS`

If `$BUNDLE_EXEC_COMMANDS` is not empty, `bundle exec` is inserted automatically if and only if the command is included in the variable.
Value of the variable must be space-separated value like below.

```sh
export BUNDLE_EXEC_COMMANDS='rails rake rspec'
```

### `$BUNDLE_EXEC_EXPAND_ALIASE`

If `$BUNDLE_EXEC_EXPAND_ALIASE` is not empty, zsh-bundle-exec expands the command to an absolute path instead of inserting `bundle exec`.
It makes command execution faster because `bundle` command is not used.  However, it makes command history dirty.

```sh
export BUNDLE_EXEC_EXPAND_ALIASE=yes
```


## License

[The MIT License](http://opensource.org/licenses/MIT)

Copyright (c) 2013 rhysd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
