# Kubernetes Job/CronJob Notifier

[![GoReport](https://goreportcard.com/badge/github.com/gumlet/k8s-job-notify)](https://goreportcard.com/report/github.com/gumlet/k8s-job-notify)
[![Docker Pulls](https://img.shields.io/docker/pulls/gumlet/k8s-job-notify.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/gumlet/k8s-job-notify/tags)

This tool sends an alert to slack whenever there is a [Kubernetes](https://github.com/kubernetes/kubernetes) cronJob/Job failure/success.

**No extra setup** required to deploy this tool on to your cluster, just apply below K8s deploy manifest 🎉

This uses `InClusterConfig` for accessing Kubernetes API.

## Limitations

- Namespace scoped i.e., each namespace should have this deploy _separately_
- **All the jobs** in the namespace are fetched and verified for failures
  - Will add support for selectors in future 📋

## Development

If you wish to run this locally, clone this repository, set `webhook` and `namespace` env variables.
This expects kube config to be in `~/.kube/config` (default)

```sh
$ export webhook="slack_webhook_url" && export namespace="<namespace_name>" && go build &&  ./k8s-job-notify
```

You can also adjust the notification level to `failed` instead of `all` so that it only sends failed notificatinos.

```sh
$ export webhook="slack_webhook_url" && export namespace="<namespace_name>" && export notification_level="failed" && go build &&  ./k8s-job-notify
```

Docker 🐳

---

Docker images are hosted at [hub.docker/k8s-job-notify](https://hub.docker.com/r/gumlet/k8s-job-notify)

## Releases

- If you want to use stable releases, please use [github release tags](https://github.com/gumlet/k8s-job-notify/releases). For example, `image: gumlet/k8s-job-notify:1.7`

## To start using this

Create and apply below kubernetes deployment in your cluster

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kjn
  name: k8s-job-notify
  namespace: <namespace_name>
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kjn
  template:
    metadata:
      annotations:
        sidecar.istio.io/inject: 'false'
      labels:
        app: kjn
    spec:
      #serviceAccountName: k8s-job-notify (optional, see RBAC)
      containers:
        - env:
            - name: webhook
              value: <slack_webhook_url> # creating a secret for this var is recommended
            - name: namespace
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: incluster
              value: '1'
            - name: "notification_level"
              value: 'all'  # or 'failed'
          image: gumlet/k8s-job-notify:<tag>
          name: k8s-job-notify
          resources:
            limits:
              cpu: 500m
              memory: 256Mi
            requests:
              cpu: 500m
              memory: 128Mi
```

If your kubernetes uses RBAC, you should apply the following manifest as well:

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: k8s-job-notify
  namespace: <namespace_name>

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: <namespace_name>
  name: job-reader
rules:
  - apiGroups: ['batch'] # "" indicates the core API group
    resources:
      - jobs
    verbs:
      - get
      - list
      - watch

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: k8s-job-notify
  namespace: <namespace_name>
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: job-reader
subjects:
  - kind: ServiceAccount
    name: k8s-job-notify
    namespace: <namespace_name>
```

If you want to show cluster name in message:

```yaml
containers:
  image: gumlet/k8s-job-notify:<tag>
  name: k8s-job-notify
  args: ['--cluster-name=<your-cluster-name>']
```

## Contributing 🤝

Contributions, issues and feature requests are welcome.

## Author

👤 Gumlet

- Twitter: [@gumlethq](https://twitter.com/gumlethq)

Please feel free to ⭐️ this repository if this project helped you! 😉

## 📝 License

Copyright © 2019-2025 Gumlet Pte. Ltd.  
This project is MIT licensed.
