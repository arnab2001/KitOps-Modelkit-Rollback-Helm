# ModelKit Demo - Version Documentation

This document describes the different model versions used in the rollback demonstration.

## Model Versions

### v0 (Working Version) - ROLLBACK TARGET
- **Tag**: `jozu.ml/arnabchat2001/modelkit-demo:v0`
- **Status**: ✅ WORKING
- **Model Version**: "GOOD"
- **Characteristics**:
  - Stable model performance
  - All health checks pass
  - Fast response times
  - No known issues
- **Use Case**: This is the version we rollback to when v1 fails

### v1 (Current BAD Version) - CURRENT PRODUCTION
- **Tag**: `jozu.ml/arnabchat2001/modelkit-demo:v1`
- **Status**: ❌ FAILING
- **Model Version**: "BAD"
- **Characteristics**:
  - Model produces incorrect responses
  - Health checks may fail intermittently
  - Performance degradation
  - Known issues with certain input types
- **Use Case**: This is the current production version that needs rollback

### v2 (Future Version) - NOT YET DEPLOYED
- **Tag**: `jozu.ml/arnabchat2001/modelkit-demo:v2`
- **Status**: 🚧 IN DEVELOPMENT
- **Model Version**: "EXPERIMENTAL"
- **Characteristics**:
  - New features and improvements
  - Under testing
  - Not ready for production
- **Use Case**: Future release after fixing v1 issues

## Rollback Scenarios

### Scenario 1: Emergency Rollback (v1 → v0)
- **Trigger**: Health check failures, model producing incorrect outputs
- **Method**: Helm upgrade or kubectl set env
- **Expected Result**: Model version changes from "BAD" to "GOOD"
- **Verification**: Health checks pass, correct model responses

### Scenario 2: Planned Rollback (v1 → v0)
- **Trigger**: Scheduled maintenance, known issues
- **Method**: Helm upgrade with values-rollback.yaml
- **Expected Result**: Smooth transition to working version
- **Verification**: Zero downtime, all services healthy

## Health Check Endpoints

- **GET /health**: Returns overall health status
- **GET /version**: Returns current model version
- **GET /model/info**: Returns detailed model information

## Rollback Commands

### Helm Method
```bash
# Rollback to v0
helm upgrade modelkit-demo ./helm-chart --set modelkitRef=jozu.ml/arnabchat2001/modelkit-demo:v0

# Or using values file
helm upgrade modelkit-demo ./helm-chart -f values-rollback.yaml
```

### Kubectl Method
```bash
# Direct environment variable update
kubectl set env deployment/modelkit-demo MODELKIT_REF=jozu.ml/arnabchat2001/modelkit-demo:v0
```

## Verification Steps

1. Check pod status: `kubectl get pods`
2. Check model version: `curl <service-url>/version`
3. Check health: `curl <service-url>/health`
4. Verify model info: `curl <service-url>/model/info`
