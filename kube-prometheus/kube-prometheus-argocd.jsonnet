local kp = (import 'example.jsonnet');

[kp[k] for k in std.objectFields(kp)]

//[kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus)] +
//[kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator)] +
//[kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter)] +
//[kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics)] +
//[kp.prometheus[name] for name in std.objectFields(kp.prometheus)] +
//[kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter)] +
//[kp.alertmanager[name] for name in std.objectFields(kp.alertmanager)] +
//[kp.grafana[name] for name in std.objectFields(kp.grafana)] +
//[kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter)] +
//[kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter)]