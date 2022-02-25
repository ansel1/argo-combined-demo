local ingress(svc) = {
    ingress: {
        apiVersion: "networking.k8s.io/v1",
        kind: "Ingress",
        metadata: {
          name: svc.metadata.name,
          annotations: {
            "ingress.kubernetes.io/ssl-redirect": "false",
            "nginx.ingress.kubernetes.io/ssl-redirect": "false",
            "ingress.kubernetes.io/rewrite-target": "/",
            "nginx.ingress.kubernetes.io/rewrite-target": "/",
            "kubernetes.io/ingress.class": "nginx"
          },
          namespace: svc.metadata.namespace,
        },
        spec: {
          rules: [{
            http: {
              paths: [{
                path: "/",
                pathType: "ImplementationSpecific",
                backend: {
                  service: {
                    name: svc.metadata.name,
                    port: {
                      number: portSpec.port
                    }
                  }
                }
              }]
            },
            host: svc.metadata.name + (if i > 0 then "-" + portSpec.name else "") + ".localdev.me"
          } for i in std.range(0, std.length(svc.spec.ports) -1)
            for portSpec in [svc.spec.ports[i]]]
        }
    }
};

local kp =
  (import 'kube-prometheus/main.libsonnet') +
  // Uncomment the following imports to enable its patches
  // (import 'kube-prometheus/addons/anti-affinity.libsonnet') +
  // (import 'kube-prometheus/addons/managed-cluster.libsonnet') +
  // (import 'kube-prometheus/addons/node-ports.libsonnet') +
  // (import 'kube-prometheus/addons/static-etcd.libsonnet') +
  // (import 'kube-prometheus/addons/custom-metrics.libsonnet') +
  // (import 'kube-prometheus/addons/external-metrics.libsonnet') +
  {
    values+:: {
      common+: {
        namespace: 'monitoring',
      },
      alertmanager+: {
        replicas: 1
      },
      prometheus+: {
        replicas: 1
      },
      prometheusAdapter+: {
        replicas: 1
      }
    },
    // mountPropagation=HostToContainer doesn't work with docker for mac
    nodeExporter+: {
        daemonset+: {
            spec+: {
                template+: {
                    spec+: {
                        containers: [
                            super.containers[0] + {
                                volumeMounts: [ m + { mountPropagation: 'None' } for m in super.volumeMounts ]
                            }
                        ] + super.containers[1:]
                    }
                }
            }
        },
    },
    // ingress for grafana
    grafana+: ingress(kp.grafana.service),
    prometheusOperator+: {
        "0prometheusCustomResourceDefinition"+: {
            metadata+: {
                annotations+: {
                    "argocd.argoproj.io/sync-options": "Replace=true"
                }
            }
        }
    }
  };



{ 'setup/0namespace-namespace': kp.kubePrometheus.namespace } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor' && name != 'prometheusRule'), std.objectFields(kp.prometheusOperator))
} +
// serviceMonitor and prometheusRule are separated so that they can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ 'prometheus-operator-prometheusRule': kp.prometheusOperator.prometheusRule } +
{ 'kube-prometheus-prometheusRule': kp.kubePrometheus.prometheusRule } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['blackbox-exporter-' + name]: kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['kubernetes-' + name]: kp.kubernetesControlPlane[name] for name in std.objectFields(kp.kubernetesControlPlane) }
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) }