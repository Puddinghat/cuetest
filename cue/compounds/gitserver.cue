package compounds

import (
    "github.com/Puddinghat/cuetest/cue/base"
	"github.com/Puddinghat/cuetest/cue/docker"
)

// docker container from https://github.com/6arms1leg/git-ssh-docker
#GitServer: {
	base.#Compound
	input="in": {
		name:    string
		version: string | *"1.1.1"
		network: string
        mounts: {
            keys: string
            keysHost: string
            repos: string
        }
	}
	dep="deps": {
		container: docker.#Container & {
			in: {
				name:  "gitserver_" + (input.name)
				image: "git-ssh:" + (input.version)
				networks: (input.network): _
                ports: "22": external: 2222
                mounts: {
                    docker.#BindMount & {
                        "/git/keys": source: input.mounts.keys
                    }
                    docker.#BindMount & {
                        "/git/keys-host": source: input.mounts.keysHost
                    }
                    docker.#BindMount & {
                        "/git/repos": source: input.mounts.repos
                    }
                }
                env: {
						"PUID": "1000"
						"PGID": "1000"
					}
			}
		}
	}

    ref: {
        container: dep.container.ref
    }
}
