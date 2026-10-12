# Dashboard Assets

This directory contains mock JSON data used for local development and testing.

The committed `*.template.json` files hold fictional demo data for a sample profile (Nova Lindqvist) in `en`, `es` and `nl`, so the app can run in demos without any personal data.

## 📁 Files

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
   cp experiences.template.json experiences.json
   cp expertise.template.json expertise.json
   cp profile.template.json profile.json
   cp projects.template.json projects.json
   cp services.template.json services.json
   cp testimonials.template.json testimonials.json
   ```

2. Keep the demo data, or edit the `.json` files with your actual data

### For CI/CD

The setup action automatically creates `.json` files from `.template.json` files during workflow runs.

This prevents `asset_does_not_exist` warnings during `dart analyze`.

## 🎛️ Switching Data Source

In builds with the developer menu enabled, use the **Use demo data** switch (Data Source section) to make the asset repositories read the `*.template.json` files instead of the `*.json` ones. The choice is persisted; restart the app to apply it. While demo data is selected, the local cache is bypassed so real and demo data never mix.

## 🤖 Testing the Assistant with Demo Data

The demo profile (Nova Lindqvist) is built so answers can be verified. Useful probes:

- Roles and timeline: 6 experiences (two overlap: full-time Aurora Commerce and part-time Independent Consulting since 2021-06)
- Counts: 11 projects, 6 services, 7 testimonials, 9 expertise groups, 3 certifications
- Multi-country project: Aurora Marketplace ships in NL, DE, BE and ES; MoveIt in SE and NO; Orbit Pay in NL and UK
- Status mix: Ongoing, Completed and Deprecated projects (for example Pixel Puzzle is Deprecated)
- Metrics: Aurora Assistant 1M+ active users, Aurora Checkout +18% conversion, Orbit Pay 150K+ downloads
- Open-source link: Aurora Design System has a GitHub URL on its market
- Intentional gaps (the assistant should say the data is not available): salary expectations, age, hobbies, soft skills

## 📝 File Structure

```
assets/dashboard/
├── README.md                     # This file (committed)
├── .gitkeep.json                 # Directory marker (committed)
├── *.template.json               # Fictional demo data (committed)
└── *.json                        # Actual data (git-ignored)
```

## ✅ Best Practices

- Keep actual `.json` files with sensitive/real data
- Templates contain fictional demo data only, never real personal data
- CI uses templates to satisfy asset requirements
- Prevents analyzer warnings without exposing data
