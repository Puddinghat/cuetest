package kubernetes

import (
	"github.com/Puddinghat/cuetest/cue/terraform"
)

#KubernetesProvider: {
    terraform.#Provider
	in: {
		name:    "kubernetes"
		source:  "hashicorp/kubernetes"
		version: "2.16.0"
		kubeconfig?: #KubeConfigConfigPaths | #KubeConfigClientCert
		if kubeconfig != _|_ {
			options: kubeconfig
		}
	}
}

#Secret: {
    terraform.#Resource
    input="in": {
        name: string
        namespace: string
        metadata: {
            labels: {...}
            annotations: {...}
        }
        type: *"Opaque" | string
        data: {...}
        refs: {
            name: path: "object.metadata.name"
        }
        id: name
        resource: "kubernetes_secret"
    }

    res: {
        metadata: {
            name: input.name
            namespace: input.namespace
            input.metadata
        }
        type: input.type
        data: input.data
    }
}

#Manifest: {
    terraform.#Resource
    input="in": {
        name: string
        namespace: string
        kind: string
        apiVersion: string
        spec: {...}
        metadata: {
            labels: {...}
            annotations: {...}
            finalizers: [...]
        }
        wait: [...]
        id: "\(kind)_\(name)"
        resource: "kubernetes_manifest"
        refs: {
            name: path: "object.metadata.name"
        }
    }

    res: {
        manifest: {
            apiVersion: input.apiVersion
            kind: input.kind
            metadata: {
                name: input.name
                namespace: input.namespace
                input.metadata
            }
            spec: input.spec
        }
        wait: input.wait
    }
}
