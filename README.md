# test-helm-charts

Test repository for Webrix Helm charts used for development and testing before production release.

## Overview

This repository contains multiple Helm charts for the MCP-S (Multi-Cloud Platform Service) stack. The main chart (`mcp-s`) serves as an umbrella chart that includes all other service charts as dependencies.

### Chart Structure

- **mcp-s** - Master/umbrella chart that orchestrates all services
- **mcp-s-app** - Application service
- **mcp-s-connect** - Connection service
- **mcp-s-run** - Runtime service
- **mcp-s-db-service** - Database service
- **mcp-s-grafana** - Monitoring with Grafana

## Local Development

### Prerequisites

- Helm 3.x installed
- Access to the Webrix container registry (if pulling images)

### Setting Up for Local Testing

When testing locally without a Helm repository, you need to build dependencies first:

```bash
cd charts/mcp-s
helm dependency build .
```

This command downloads all dependent charts specified in `Chart.yaml` and places them in the `charts/` directory.

## Configuration and Overrides

Helm provides multiple ways to override default values:

1. **Using `--set` flags** (inline overrides)
2. **Using values files** with `-f values.yaml`
3. **Combining both methods**

### Override Examples

#### Testing App Service Configuration
```bash
helm template . --set app.replicas=1000 --set app.appVersion=ttttttt -f values.yaml --debug | grep -E "(image|replicas)" -B 3 -A 3
```

#### Testing Connect Service Configuration
```bash
helm template . --set connect.replicas=1000 --set connect.appVersion=ttttttt -f values.yaml --debug | grep -E "(image|replicas)" -B 3 -A 3
```

#### Testing Run Service Configuration
```bash
helm template . --set run.replicas=1000 --set run.appVersion=ttttttt -f values.yaml --debug | grep -E "(image|replicas)" -B 3 -A 3
```

#### Testing DB Service Configuration
```bash
helm template . --set dbservice.replicas=1000 --set dbservice.appVersion=ttttttt -f values.yaml --debug | grep -E "(image|replicas)" -B 3 -A 3
```

> **Note**: The db-service chart uses an alias `dbservice` in the dependencies because Helm doesn't support hyphens in subchart value keys. This is defined in the `Chart.yaml` dependencies section.

### Understanding the Output

The `grep` command with `-B 3 -A 3` shows 3 lines before and after matches, helping you verify:
- Image tags are correctly set
- Replica counts are properly configured
- The context around these settings

## Testing Workflow

1. **Make changes** to your values or chart templates
2. **Build dependencies** if you've modified dependency versions
3. **Template the chart** to see the generated Kubernetes manifests
4. **Validate** the output matches your expectations
5. **Deploy** to a test cluster when ready

## Values File Structure

The `values.yaml` file in the mcp-s chart can override values for all subcharts:

```yaml
# Override for app service
app:
  replicas: 3
  appVersion: "v1.2.3"

# Override for connect service  
connect:
  replicas: 2
  appVersion: "v1.2.3"

# Override for db-service (using alias)
dbservice:
  replicas: 1
  appVersion: "v1.2.3"
```

## Dynamic Environment Variables

All dependency charts support dynamic environment variables. This allows you to inject custom environment variables into any service container at runtime without modifying the chart templates.

### How It Works

Any environment variable set under the `.env` key of a dependency chart will be automatically injected into the target container's environment variables.

### Syntax

```bash
--set <service>.env.<ENV_VAR_NAME>=<value>
```

### Examples

#### Setting Environment Variables for Connect Service
```bash
helm template . --set connect.env.THIS_IS_TEST=1 --set connect.env.DEBUG_MODE=true -f values.yaml
```

#### Setting Environment Variables for App Service
```bash
helm template . --set app.env.LOG_LEVEL=debug --set app.env.FEATURE_FLAG=enabled -f values.yaml
```

#### Setting Environment Variables for DB Service
```bash
helm template . --set dbservice.env.DB_POOL_SIZE=20 --set dbservice.env.TIMEOUT=30s -f values.yaml
```

### Testing Dynamic Environment Variables

To verify that environment variables are correctly set, use grep to filter the templated output:

```bash
# Test connect service environment variables
helm template . --set connect.env.THIS_IS_TEST=1 --set connect.env.DEBUG_MODE=true -f values.yaml --debug | grep -E "(THIS_IS_TEST|DEBUG_MODE)" -B 2 -A 2

# Test multiple services with environment variables
helm template . --set app.env.LOG_LEVEL=debug --set connect.env.API_TIMEOUT=60s -f values.yaml --debug | grep -E "(LOG_LEVEL|API_TIMEOUT)" -B 2 -A 2
```

### Using Values Files for Environment Variables

You can also define environment variables in your `values.yaml`:

```yaml
connect:
  env:
    THIS_IS_TEST: "1"
    DEBUG_MODE: "true"
    API_ENDPOINT: "https://api.example.com"

app:
  env:
    LOG_LEVEL: "debug"
    CACHE_TTL: "3600"

dbservice:
  env:
    DB_POOL_SIZE: "20"
    CONNECTION_TIMEOUT: "30s"
```


## Deployment

For actual deployment to a Kubernetes cluster:

```bash
helm install mcp-s ./charts/mcp-s -f values.yaml --namespace your-namespace
```

Or for upgrades:

```bash
helm upgrade mcp-s ./charts/mcp-s -f values.yaml --namespace your-namespace
```

## Troubleshooting

- If dependency build fails, check your `Chart.yaml` for correct chart names and versions
- Use `helm template` with `--debug` flag to see detailed output
- For subchart overrides not working, verify the alias names in the dependencies
- Check that your values path matches the dependency alias (e.g., `dbservice.replicas` not `db-service.replicas`)