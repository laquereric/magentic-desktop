# Secrets Directory Structure

This directory contains example files showing the structure of the `.secrets` directory used by the magentic-desktop deployment scripts.

## Directory Structure

```
.secrets/
├── roles/
│   ├── admin/
│   │   └── [admin_username]          # Admin user files
│   └── partner/
│       └── [partner_username]        # Partner user files
├── services/
│   ├── nebius/
│   │   └── set_env.sh                # Nebius cloud platform credentials
│   └── github/
│       └── set_env.sh                # GitHub service credentials
└── users/
    └── [username]/
        ├── set_env.sh                # User-specific environment variables
        ├── id_ed25519                # SSH private key
        └── id_ed25519.pub            # SSH public key
```

## Setup Instructions

1. **Copy the example structure:**
   ```bash
   cp -r .secrets_example .secrets
   ```

2. **Replace example values with real credentials:**
   - Update all `set_env.sh` files with actual environment variables
   - Replace SSH keys with your actual keys
   - Update usernames in role files and directory names

3. **Set proper permissions:**
   ```bash
   chmod 600 .secrets/users/*/id_ed25519
   chmod 644 .secrets/users/*/id_ed25519.pub
   chmod 600 .secrets/**/set_env.sh
   ```

## Security Notes

- Never commit the actual `.secrets` directory to version control
- Keep all credential files with restricted permissions (600)
- Use strong, unique credentials for each service
- Regularly rotate access keys and tokens

## Environment Variables

### Nebius Service (`services/nebius/set_env.sh`)
- `NB_PROFILE_NAME`: Your Nebius profile name
- `NB_PROJECT_ID`: Your Nebius project ID

### GitHub Service (`services/github/set_env.sh`)
- `GITHUB_TOKEN`: Your GitHub personal access token
- `GITHUB_USERNAME`: Your GitHub username
- `GITHUB_EMAIL`: Your GitHub email

### User Environment (`users/[username]/set_env.sh`)
- `CP`: GitHub token (for compatibility)
- `GITHUB_USERNAME`: GitHub username
- `REMOTE_USERNAME`: Username for remote server access
- `LOCAL_USERNAME`: Local system username
- `PUBLIC_IP`: Public IP address of the deployment server
