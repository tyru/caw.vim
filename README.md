# Build Status

| Service        | Status           |
| ------------- |:-------------:| -----:|
| Travis CI | [![Travis CI](https://travis-ci.org/tyru/caw.vim.svg?branch=master)](https://travis-ci.org/tyru/caw.vim) |
| AppVeyor | [![AppVeyor](https://ci.appveyor.com/api/projects/status/9ewm3btund11qrlp/branch/master?svg=true)](https://ci.appveyor.com/project/tyru/caw.vim/branch/master) |


# Features

* Supports 300+ filetypes (see `|caw-supported-filetypes|`).
  * But caw.vim does not slow down your Vim startup because each comment
    string are defined at ftplugin files (`after/ftplugin/<filetype>/caw.vim`).
* Supports operator keymappings (`|caw-keymappings-operator|`).
  * If `|g:caw_operator_keymappings|` is non-zero, all default keymappings map
    to operator keymappings.
  * If you need [kana/vim-operator-user](https://github.com/kana/vim-operator-user) to use operator keymappings.
* Supports also non-operator keymappings (`|caw-keymappings-non-operator|`).
* Dot-repeatable if you installed [kana/vim-repeat](https://github.com/kana/vim-repeat)
* The comment behavior only depends on 'filetype' by default.
  But if you have installed [Shougo/context\_filetype.vim](https://github.com/Shougo/context_filetype.vim), caw.vim also depends on the
  filetype of the context of the current cursor location.
  So you can comment/uncomment JavaScript in HTML correctly.
* Well-tested powered by [thinca/vim-themis](https://github.com/thinca/vim-themis)


# Hot it works

The below are the examples in "filetype=c".
caw.vim supports 300+ filetypes (see |caw-supported-filetypes|).

```
Type "gci" (toggle: "gcc", uncomment: "gcui")
  before:
      "   <- inserted here"
  after:
      "   # <- inserted here"

Type "gcI" (uncomment: "gcuI")
  before:
      "   inserted the first column"
  after:
      "#    inserted the first column"

Type "gca" (uncomment: "gcua")
  before:
      "inserted after this"
  after:
      "inserted after this    # "

Type "gcw" (uncomment: "gcuw")
  before:
      "  wrap!"
  after:
      "  /* wrap! */"

Type "gcb"
  before:
      "  box!"
  after:
      "  /********/"
      "  /* box! */"
      "  /********/"

Type "gco"
  before:
      "   func1();"
  after:
      "   func1()"
      "   // "  (now cursor is at the end and entered insert-mode)

Type "gcO"
  before:
      "   func1();"
  after:
      "   // "  (now cursor is at the end and entered insert-mode)
      "   func1();"
```
