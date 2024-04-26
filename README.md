# demo-actions-azure-keyvault

This repository contains a demo of using GitHub Actions with Federated/ODIC Authentication to pull a secret from Azure Key Vault.

## Authentication to Azure

The GitHub Action authenticates to Azure as a service principal; however, instead of managing secrets in GitHub, this implements Federated Authentication with OIDC.

Documentation:

- [Configuring OpenID Connect in Azure - GitHub Docs](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Authenticate to Azure from GitHub Action workflows | Microsoft Learn](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Clinux)

## Demo

1. Fork this repository
1. Configure Azure infrastructure (see: [Infrastructure Configuration](#infrastructure-configuration))
    - Service Principal
    - Key Vault
    - Role assignment
1. Set up GitHub secrets for Actions (see: [GitHub Configuration](#github-configuration))
1. Execute Action

The Action runs manully from the `Actions` tab in this repository.

### Actions Steps

The Action steps are defined in [`get-azure-secrets.yml`](.github/workflows/azure-get-secrets.yml).

1. **Azure Login:** Logs into Azure CLI with Federated Credentials (OIDC). This eliminates the need to manage a client ID and secret.
1. **Get Secrets:** This will fetch additional secrets from Azure Key Vault, using the identity from the Login step.
1. **Show Secrets:** This will output the secrets from the Get Secrets step, showing that the `secret2` value is masked.

### Result

The log will show a result, one of a plaintext `secret1` value and the other of a masked `secret2` value:

```text
secret1: value1
secret2: ***
```

## Infrastructure Configuration

If you wish to fork and run this demo in your environment, you will need to provision a Key Vault in Azure and grant the service principal used in Actions the `Key Vault Secrets User` role or assign the appropriate legacy Key Vault access policy.

Documentation: 

- [Grant permission to applications to access an Azure key vault using Azure RBAC | Microsoft Learn](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli)

You can reference or use the [`deploy.sh`](infra/deploy.sh) script in this repository to assist with setting up a demo environment.

### GitHub Configuration

GitHub Actions will also expect the following secrets to be configured in the repository:

- `AZURE_TENANT_ID`: The tenant ID for your Azure environment
- `AZURE_CLIENT_ID`: Your Azure service principal client ID
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID
- `AZURE_KEY_VAULT_NAME`: The name of the Azure Key Vault
