local kp = (import 'kube-prometheus/main.libsonnet') + {
    values+:: {
        common+: {
            namespace: 'monitoring',
        },
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
        }
    }
};

[kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus)] +
[kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator)] +
[kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter)] +
[kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics)] +
[kp.prometheus[name] for name in std.objectFields(kp.prometheus)] +
[kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter)] +
[kp.alertmanager[name] for name in std.objectFields(kp.alertmanager)] +
[kp.grafana[name] for name in std.objectFields(kp.grafana)] +
[kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter)] +
[kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter)]