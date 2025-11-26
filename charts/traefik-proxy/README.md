# Traefik-Proxy

A Helm chart app encapsulating most of the Traefik resource configurations.

You can install the chart with the command:

```bash
helm repo add swanlab https://helm.swanlab.cn
helm install traefik-proxy swanlab/traefik-proxy
```

We have built in a local plugin:

```yaml
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: identify
spec:
  plugin:
    identify:
      AuthUrl: "http://swanlab-server:3000/api/identity"
```

Note: by default, ingressClass is set to `traefik-proxy`, and isDefaultClass is set to `false`. You may need to adjust these values based on your cluster configuration.