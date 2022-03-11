function (
    is_offline=false,
    private_registry="registry.tmaxcloud.org"
)

local quay_registry = if is_offline == false then "quay.io" else private_registry;

[
    {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "name": "cert-manager-cainjector",
            "namespace": "cert-manager",
            "labels": {
                "app": "cainjector",
                "app.kubernetes.io/name": "cainjector",
                "app.kubernetes.io/instance": "cert-manager",
                "app.kubernetes.io/component": "cainjector",
                "app.kubernetes.io/version": "v1.5.4"
            }
        },
        "spec": {
            "replicas": 1,
            "selector": {
                "matchLabels": {
                    "app.kubernetes.io/name": "cainjector",
                    "app.kubernetes.io/instance": "cert-manager",
                    "app.kubernetes.io/component": "cainjector"
                }
            },
            "template": {
                "metadata": {
                    "labels": {
                        "app": "cainjector",
                        "app.kubernetes.io/name": "cainjector",
                        "app.kubernetes.io/instance": "cert-manager",
                        "app.kubernetes.io/component": "cainjector",
                        "app.kubernetes.io/version": "v1.5.4"
                    }
                },
                "spec": {
                    "serviceAccountName": "cert-manager-cainjector",
                    "securityContext": {
                        "runAsNonRoot": true
                    },
                    "containers":  [
                        { 
                            "name": "cert-manager",
                            "image": std.join("", [quay_registry, "/jetstack/cert-manager-cainjector:v1.5.4"]),
                            "imagePullPolicy": "IfNotPresent",
                            "args": [
                              "--v=2",
                              "--leader-election-namespace=kube-system",
                            ],
                            "env": [
                              { 
                                "name": "POD_NAMESPACE",
                                "valueFrom": {
                                  "fieldRef": {
                                      "fieldPath": "metadata.namespace"
                                  }
                                }
                              }
                            ],
                            "resources": {}
                            "volumeMounts": [
                                {
                                    "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                                    "name": "cert-manager-secret"
                                }
                            ]
                        }
                    ],
                    "volumes": [
                        {
                            "name": "cert-manager-cainjector-secret"
                            "secret": {
                                "secretName": "cert-manager-cainjector-token"
                            }
                        }
                    ]
                }
            }
        }
    },
    {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "name": "cert-manager",
            "namespace": "cert-manager",
            "labels": {
                "app": "cert-manager",
                "app.kubernetes.io/name": "cert-manager",
                "app.kubernetes.io/instance": "cert-manager",
                "app.kubernetes.io/component": "controller",
                "app.kubernetes.io/version": "v1.5.4"
            }
        },
        "spec": {
            "replicas": 1,
            "selector": {
                "matchLabels": {
                    "app.kubernetes.io/name": "cert-manager",
                    "app.kubernetes.io/instance": "cert-manager",
                    "app.kubernetes.io/component": "controller"
                }
            },
            "template": {
                "metadata": {
                    "labels": {
                        "app": "cert-manager",
                        "app.kubernetes.io/name": "cert-manager",
                        "app.kubernetes.io/instance": "cert-manager",
                        "app.kubernetes.io/component": "controller",
                        "app.kubernetes.io/version": "v1.5.4"
                    },
                    "annotations": {
                        "prometheus.io/path": "/metrics",
                        "prometheus.io/scrape": "true",
                        "prometheus.io/port": "9402"
                    }
                },
                "spec": {
                    "serviceAccountName": "cert-manager",
                    "securityContext": {
                        "runAsNonRoot": true
                    },
                    "containers":  [
                        { 
                            "name": "cert-manager",
                            "image": std.join("", [quay_registry, "/jetstack/cert-manager-controller:v1.5.4"]),
                            "imagePullPolicy": "IfNotPresent",
                            "args": [
                              "--v=2",
                              "--cluster-resource-namespace=$(POD_NAMESPACE)",
                              "--leader-election-namespace=kube-system"
                            ],
                            "ports" : [
                                {
                                    "containerPort": 9402,
                                    "protocol" : "TCP"
                                }
                            ],
                            "env": [
                              { 
                                "name": "POD_NAMESPACE",
                                "valueFrom": {
                                  "fieldRef": {
                                      "fieldPath": "metadata.namespace"
                                  }
                                }
                              }
                            ],
                            "resources": {},
                            "volumeMounts": [
                                {
                                    "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                                    "name": "cert-manager-secret"
                                }
                            ]
                        }
                    ],
                    "volumes": [
                        {
                            "name": "cert-manager-secret"
                            "secret": {
                                "secretName": "cert-manager-token"
                            }
                        }
                    ]
                }
            }
        }
    },
    {
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "metadata": {
            "name": "cert-manager-webhook",
            "namespace": "cert-manager",
            "labels": {
                "app": "webhook",
                "app.kubernetes.io/name": "webhook",
                "app.kubernetes.io/instance": "cert-manager",
                "app.kubernetes.io/component": "webhook",
                "app.kubernetes.io/version": "v1.5.4"
            }
        },
        "spec": {
            "replicas": 1,
            "selector": {
                "matchLabels": {
                    "app.kubernetes.io/name": "webhook",
                    "app.kubernetes.io/instance": "cert-manager",
                    "app.kubernetes.io/component": "webhook"
                }
            },
            "template": {
                "metadata": {
                    "labels": {
                        "app": "webhook",
                        "app.kubernetes.io/name": "webhook",
                        "app.kubernetes.io/instance": "cert-manager",
                        "app.kubernetes.io/component": "webhook",
                        "app.kubernetes.io/version": "v1.5.4"
                    }
                },
                "spec": {
                    "serviceAccountName": "cert-manager-webhook",
                    "securityContext": {
                        "runAsNonRoot": true
                    },
                    "containers":  [
                        { 
                            "name": "cert-manager",
                            "image": std.join("", [quay_registry, "/jetstack/cert-manager-webhook:v1.5.4"]),
                            "imagePullPolicy": "IfNotPresent",
                            "args": [
                              "--v=2",
                              "--secure-port=10250",
                              "--dynamic-serving-ca-secret-namespace=$(POD_NAMESPACE)",
                              "--dynamic-serving-ca-secret-name=cert-manager-webhook-ca",
                              "--dynamic-serving-dns-names=cert-manager-webhook,cert-manager-webhook.cert-manager,cert-manager-webhook.cert-manager.svc"
                            ],
                            "ports" : [
                                {   
                                    "name": "https",
                                    "protocol" : "TCP",
                                    "containerPort": 10250
                                }
                            ],
                            "livenessProbe": {
                                "httpGet": {
                                    "path": "/livez",
                                    "port": 6080,
                                    "scheme": "HTTP"
                                },
                                "initialDelaySeconds": 60,
                                "periodSeconds": 10,
                                "timeoutSeconds": 1,
                                "successThreshold": 1,
                                "failureThreshold": 3
                            },
                            "readinessProbe": {
                                "httpGet": {
                                    "path": "/healthz",
                                    "port": 6080,
                                    "scheme": "HTTP"
                                },
                                "initialDelaySeconds": 5,
                                "periodSeconds": 5,
                                "timeoutSeconds": 1,
                                "successThreshold": 1,
                                "failureThreshold": 3
                            },
                            "env": [
                              { 
                                "name": "POD_NAMESPACE",
                                "valueFrom": {
                                  "fieldRef": {
                                      "fieldPath": "metadata.namespace"
                                  }
                                }
                              }
                            ],
                            "resources": {},
                            "volumeMounts": [
                                {
                                    "mountPath": "/var/run/secrets/kubernetes.io/serviceaccount",
                                    "name": "cert-manager-webhook-secret"
                                }
                            ]
                        }
                    ],
                    "volumes": [
                        {
                            "name": "cert-manager-webhook-secret"
                            "secret": {
                                "secretName": "cert-manager-webhook-token"
                            } 
                        }
                    ]
                }
            }
        }
    }
]
