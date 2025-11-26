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

For flexibility, we have not predefined a schema for traefik-proxy.
If you have some understanding of [traefik](https://helm.traefik.io/traefik), you can freely configure the relevant parameter values under the `traefik` property. 
Otherwise, we recommend using the `traefik` helm directly, as it is more versatile:

```bash
helm repo add traefik https://helm.traefik.io/traefik

helm install traefik traefik/traefik
```

> Note: by default, [providers.kubernetesCRD.labelSelector](https://doc.traefik.io/traefik/reference/install-configuration/providers/kubernetes/kubernetes-crd/#opt-providers-kubernetesCRD-labelselector) is set to `swanlab=traefik-proxy`. You may need to adjust these values based on your cluster configuration.