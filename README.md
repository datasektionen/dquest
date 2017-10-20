# dquest
dQuest is a service for requesting work on projects.  Better
explanation will come whenever someone feels like writing it.




## Shit you gotta know
Well first of this is written in haskell and you probably should know
the basics of haskell before you continue.

### Structure
Because this uses haskell for every part of the service (server and
client) The project is split into three parts "client" "server" and
"shared".  This is since ghcjs is unable to compile some haskell code
that are only available to native environments.
#### Client
Contains all code specific for the frontend. Aka shit that gets
compiled into javascript. This is written in haskell using ghcjs.

#### Server
Contains all code specific only to the server

#### Shared
Contains all diffent data types for the project that isn't specific to either the server or the client. That is both parts are able to use them.

### Stack
This project uses stack as a build and package management tool. Read
up on the strucutre there. But basicly there are cabal files that
contain any depencencies and defenitions of the libraries and
exeutables. As well as a stack.yaml file where specifics about each
part of the project is written.



### Servant
Servant is the webserver and "framework" used it the project. It
contains a few confusing things for the new and medium experienced
haskeller alike. There is a great tutorial here:
http://haskell-servant.readthedocs.io/en/stable/

The type for the API can be found in the shared package

### Ghcjs

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
