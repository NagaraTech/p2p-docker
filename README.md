
## Init

> The .gitmodules file can be modified according to your requirements, such as specifying branches, commits, tags, etc.

To download the submodule repositories listed in the .gitmodules file
`git submodule update --init --recursive`

You want to manually update the submodules to the latest commits
`git submodule update --remote`

## Build

`docker build -t p2p .`

## Run

`docker run -p 33334:33333 -e PARAMS="--id hello1 --remote tcp://192.168.2.9:33333" --name hello1 p2p:latest`

**options**
```sh
-v ./config-tempelete.yaml:/app/config-tempelete.yaml
-v ./start_services.sh:/usr/local/bin/start_services.sh
```
