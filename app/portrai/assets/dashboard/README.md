# Dashboard Assets

This directory contains mock JSON data used for local development and testing.

## 📁 Files

- `portfolio.json` - Portfolio items data
- `experiences.json` - Work experience data
- `expertise.json` - Skills and expertise data
- `profile.json` - Profile information
- `projects.json` - Project showcase data
- `services.json` - Services offered data
- `testimonials.json` - Client testimonials data

## 🔒 Privacy

**These files are git-ignored** to keep your personal/staging data private.

## 🚀 Setup

### For Local Development

1. Copy the `.template.json` files:
   ```bash
   cd app/portrai/assets/dashboard
   cp portfolio.template.json portfolio.json
   cp experiences.template.json experiences.json
   cp expertise.template.json expertise.json
   cp profile.template.json profile.json
   cp projects.template.json projects.json
   cp services.template.json services.json
   cp testimonials.template.json testimonials.json
   ```

2. Edit the `.json` files with your actual data

### For CI/CD

The setup action automatically creates `.json` files from `.template.json` files during workflow runs.

This prevents `asset_does_not_exist` warnings during `dart analyze`.

## 📝 File Structure

```
assets/dashboard/
├── README.md                     # This file (committed)
├── .gitkeep.json                 # Directory marker (committed)
├── *.template.json               # Empty templates (committed)
└── *.json                        # Actual data (git-ignored)
```

## ✅ Best Practices

- Keep actual `.json` files with sensitive/real data
- Templates remain empty arrays/objects
- CI uses templates to satisfy asset requirements
- Prevents analyzer warnings without exposing data
