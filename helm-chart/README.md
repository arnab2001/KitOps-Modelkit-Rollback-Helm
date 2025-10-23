# ModelKit Demo Helm Chart

This Helm chart demonstrates rollback capabilities for ModelKit-based applications using both GitOps and imperative operations.

## Chart Structure

```
helm-chart/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values
├── values-prod.yaml        # Production values (v1 - BAD)
├── values-rollback.yaml    # Rollback values (v0 - GOOD)
├── templates/
│   ├── _helpers.tpl        # Template helpers
│   ├── deployment.yaml     # Main deployment template
│   └── service.yaml        # Service template
└── README.md               # This file
```

## Quick Start

### 1. Deploy Production Version (BAD)
```bash
helm upgrade --install modelkit-demo ./helm-chart \
  -f values-prod.yaml \
  --namespace default
```

### 2. Check Status
```bash
# Check pods
kubectl get pods -l app.kubernetes.io/name=modelkit-demo

# Check model version
kubectl exec <pod-name> -- curl -s localhost:8000/version
```

### 3. Rollback Methods

#### Method A: Helm Upgrade
```bash
helm upgrade modelkit-demo ./helm-chart \
  --set modelkitRef=jozu.ml/arnabchat2001/modelkit-demo:v0
```

#### Method B: kubectl set env
```bash
kubectl set env deployment/modelkit-demo \
  MODELKIT_REF=jozu.ml/arnabchat2001/modelkit-demo:v0
```

## Configuration

### Key Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `modelkitRef` | ModelKit reference for both model and code | `jozu.ml/arnabchat2001/modelkit-demo:v1` |
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Container image repository | `python` |
| `image.tag` | Container image tag | `3.11` |
| `service.port` | Service port | `8000` |

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MODEL_PATH` | Path to model files | `/model` |
| `ENVIRONMENT` | Environment name | `production` |

## Model Versions

- **v0**: Working version (GOOD) - Use for rollback
- **v1**: Current production (BAD) - Needs rollback
- **v2**: Future version (EXPERIMENTAL) - Not ready

## Health Checks

- **GET /health**: Overall health status
- **GET /version**: Current model version
- **GET /model/info**: Detailed model information

## Demo Script

Use the provided `demo-script.sh` for an interactive demonstration:

```bash
./demo-script.sh
```

## Rollback Scenarios

### Emergency Rollback
1. Detect issue (health check fails, wrong model version)
2. Execute rollback command
3. Verify pods restart with new init containers
4. Confirm health checks pass

### Planned Rollback
1. Schedule maintenance window
2. Use Helm upgrade with values-rollback.yaml
3. Monitor rollout progress
4. Verify zero downtime

## Troubleshooting

### Common Issues

1. **Pods not starting**: Check init container logs
   ```bash
   kubectl logs <pod-name> -c kitops-init-model
   ```

2. **Model not loading**: Verify MODELKIT_REF is correct
   ```bash
   kubectl describe pod <pod-name>
   ```

3. **Service not accessible**: Check service and pod labels
   ```bash
   kubectl get svc -l app.kubernetes.io/name=modelkit-demo
   ```

### Useful Commands

```bash
# Check Helm releases
helm list

# Check deployment status
kubectl rollout status deployment/modelkit-demo

# View logs
kubectl logs -l app.kubernetes.io/name=modelkit-demo

# Port forward for testing
kubectl port-forward svc/modelkit-demo 8000:8000
```
