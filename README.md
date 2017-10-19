# dquest

dQuest is a blablabla






## Development
Sadly there are a few quirks to build all the code in the project as
everything is written in haskell. Yes even the frontent. So heres what
you need to do if you want to write some code on your local machine.

Please note this is written 2017-10-14 and might be outdated in ze
future.

### 1 Install haskell platform
Not super necesarry if you're a minimalist but this is really easy.
Go here: https://www.haskell.org/platform/#linux-generic And download
it. Then untar it ``` shell tar xf
haskell-platform-8.2.1-unknown-posix--full-x86_64.tar.gz sudo
./install-haskell-platform.sh ```

If you have a system with position independent executables by default
(such as Ubuntu 16.10 and above), you should edit the GHC settings
file at:
```
usr/local/haskell/ghc-___/lib/ghc-___/settings
```
and change the `compiler supports -no-pie` flag from "NO" to "YES".

### Setup stack
Stack is a kinda nice package manager for haskell but it need to set
up some things.

```
stack setup
stack install --system-ghc cabal-install
```

The second line is only necesary since ghcjs cant work with cabal
2.0. This makes stack install its own version of cabal instead of the
system wide one.


### Install ghcjs
Go to the project directory and run:
!!!!! Warning it will rebuild all of GHC and will take some time.
```
stack setup
```



### Code
