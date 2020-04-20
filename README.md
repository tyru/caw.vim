# Build Status

![](https://github.com/tyru/caw.vim/workflows/Run%20tests/badge.svg)
![](https://github.com/tyru/caw.vim/workflows/Reviewdog/badge.svg)
![](https://github.com/tyru/caw.vim/workflows/Generate%20ftplugins/badge.svg)
![](https://github.com/tyru/caw.vim/workflows/Vim%20helptags/badge.svg)

# Requirements

* Vim 8.0 or later

# Features

* Supports 300+ filetypes (`:help caw-supported-filetypes`).
  * But caw.vim does not slow down your Vim startup because each comment
    string are defined at ftplugin files (`after/ftplugin/<filetype>/caw.vim`).
* Supports operator keymappings (`:help caw-keymappings-operator`).
  * If `g:caw_operator_keymappings` is non-zero, all default keymappings map
    to operator keymappings.
  * If you need [kana/vim-operator-user](https://github.com/kana/vim-operator-user) to use operator keymappings.
* Supports also non-operator keymappings (`:help caw-keymappings-non-operator`).
* Dot-repeatable if you installed [kana/vim-repeat](https://github.com/kana/vim-repeat)
* The comment behavior only depends on 'filetype' by default.
  But if you have installed [Shougo/context\_filetype.vim](https://github.com/Shougo/context_filetype.vim), caw.vim also depends on the
  filetype of the context of the current cursor location.
  So you can comment/uncomment JavaScript in HTML correctly.
* Well-tested powered by [thinca/vim-themis](https://github.com/thinca/vim-themis)


# How it works

The below are the examples in "filetype=c".
caw.vim supports 300+ filetypes (`:help caw-supported-filetypes`).

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
